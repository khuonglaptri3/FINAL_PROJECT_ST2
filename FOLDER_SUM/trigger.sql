--1 ngan xoa khach hang da phat sinh hoa don  
CREATE TRIGGER trg_PreventDeleteKH
ON KHACH_HANG
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 FROM MUA M
        JOIN deleted D ON M.MaKH = D.MaKH
    )
    BEGIN
        RAISERROR('Không thể xóa khách hàng đã phát sinh hóa đơn.', 16, 1);
        ROLLBACK;
    END
    ELSE
    BEGIN
        DELETE FROM KHACH_HANG WHERE MaKH IN (SELECT MaKH FROM deleted);
    END
END;
GO
-- trigger 2 : cap nhat tong tien o bang mua khi nhap them san pham o chi tiet mua 
CREATE OR ALTER TRIGGER trg_UpdateTongTien
ON CHI_TIET_MUA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Lấy các MaHD bị ảnh hưởng từ cả inserted và deleted
    DECLARE @MaHDs TABLE (MaHD INT);

    INSERT INTO @MaHDs (MaHD)
    SELECT MaHD FROM inserted
    UNION
    SELECT MaHD FROM deleted;

    -- Cập nhật lại TongTien cho từng MaHD
    UPDATE M
    SET TongTien = ISNULL((
        SELECT SUM(
            CTM.SoLuong * MH.DonGia 
            * (1 - ISNULL(CTM.ChietKhau, 0) / 100.0) 
            * (1 + ISNULL(CTM.VAT, 0) / 100.0)
        )
        FROM CHI_TIET_MUA CTM
        JOIN MAT_HANG MH ON CTM.MaSP = MH.MaSP
        WHERE CTM.MaHD = M.MaHD
    ), 0)
    FROM MUA M
    INNER JOIN @MaHDs T ON M.MaHD = T.MaHD;
END;
GO
-- trigger 3 :  cập nhật lại số lượng tồn kho khi xóa sản phẩm khỏi chi tiết mua hàng 
CREATE OR ALTER TRIGGER trg_TraLaiTonKho_KhiXoa
ON CHI_TIET_MUA
AFTER DELETE
AS
BEGIN
    -- Cộng lại số lượng vào bảng MAT_HANG
    UPDATE MH
    SET MH.SLTonKho = MH.SLTonKho + D.SoLuong
    FROM MAT_HANG MH
    JOIN DELETED D ON MH.MaSP = D.MaSP;
END;
GO

-- trigger cap nhat lai diem tich luy the thanh vien. 
CREATE OR ALTER TRIGGER trg_TaoVaCapNhatTheThanhVien
ON CHI_TIET_MUA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaHDs TABLE (MaHD INT);

    INSERT INTO @MaHDs (MaHD)
    SELECT MaHD FROM INSERTED
    UNION
    SELECT MaHD FROM DELETED;

    DECLARE @MaKH INT, @MaHD INT;

    DECLARE cur CURSOR FOR
        SELECT M.MaKH, M.MaHD
        FROM MUA M
        JOIN @MaHDs T ON M.MaHD = T.MaHD;

    OPEN cur;
    FETCH NEXT FROM cur INTO @MaKH, @MaHD;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Nếu chưa có thẻ và hóa đơn > 300K → tạo thẻ mới
        DECLARE @HoaDonHienTai DECIMAL(18,2);
        SELECT @HoaDonHienTai = TongTien FROM MUA WHERE MaHD = @MaHD;

        IF NOT EXISTS (SELECT 1 FROM THE_THANH_VIEN WHERE MaKH = @MaKH) AND @HoaDonHienTai >= 300000
        BEGIN
            INSERT INTO THE_THANH_VIEN (MaKH, Ngaycap, Maloaithe, DiemTichLuy)
            VALUES (@MaKH, GETDATE(), NULL, 0);
        END

        -- Nếu đã có thẻ → tính lại điểm
        IF EXISTS (SELECT 1 FROM THE_THANH_VIEN WHERE MaKH = @MaKH)
        BEGIN
            -- Cộng điểm từ tất cả hóa đơn của KH
            DECLARE @TongDiem INT = 0, @TmpTongTien DECIMAL(18,2), @Diem INT;

            DECLARE hd_cur CURSOR FOR
                SELECT TongTien FROM MUA WHERE MaKH = @MaKH;

            OPEN hd_cur;
            FETCH NEXT FROM hd_cur INTO @TmpTongTien;

            WHILE @@FETCH_STATUS = 0
            BEGIN
                SET @Diem = 
                    CASE 
                        WHEN @TmpTongTien < 300000 THEN 0
                        WHEN @TmpTongTien BETWEEN 300000 AND 1000000 THEN 2
                        WHEN @TmpTongTien BETWEEN 1000001 AND 2000000 THEN 6
                        WHEN @TmpTongTien BETWEEN 2000001 AND 6000000 THEN 15
                        WHEN @TmpTongTien > 6000000 THEN 30
                        ELSE 0
                    END;

                SET @TongDiem += @Diem;

                FETCH NEXT FROM hd_cur INTO @TmpTongTien;
            END

            CLOSE hd_cur;
            DEALLOCATE hd_cur;

            -- Cập nhật điểm
            UPDATE THE_THANH_VIEN
            SET DiemTichLuy = @TongDiem
            WHERE MaKH = @MaKH;

            -- Cập nhật loại thẻ theo điểm
            DECLARE @LoaiThe INT;

            SELECT TOP 1 @LoaiThe = Maloaithe
            FROM LOAI_THE_THANH_VIEN
            WHERE 
            (@TongDiem BETWEEN 10 AND 23 AND Tenloaithe = N'Bạc') OR
            (@TongDiem BETWEEN 24 AND 49 AND Tenloaithe = N'Vàng') OR
            (@TongDiem BETWEEN 50 AND 80 AND Tenloaithe = N'Bạch Kim') OR
            (@TongDiem > 80 AND Tenloaithe = N'Kim Cương') OR
            (@TongDiem BETWEEN 0 AND 9 AND Tenloaithe = N'Không có')
            ORDER BY Maloaithe;

            IF @LoaiThe IS NOT NULL
            BEGIN
                UPDATE THE_THANH_VIEN
                SET Maloaithe = @LoaiThe
                WHERE MaKH = @MaKH;
            END
        END

        FETCH NEXT FROM cur INTO @MaKH, @MaHD;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO
-- trigger tu dong xoa cac san pham o chi tiet hoa don khi xoa hoa don ---


CCREATE OR ALTER TRIGGER trg_XoaHoaDonVaChiTietMua
ON MUA
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Xóa chi tiết mua trước
    DELETE FROM CHI_TIET_MUA
    WHERE MaHD IN (SELECT MaHD FROM DELETED);

    -- Xóa hóa đơn
    DELETE FROM MUA
    WHERE MaHD IN (SELECT MaHD FROM DELETED);

    -- Cập nhật lại điểm tích lũy và loại thẻ
    DECLARE @MaKH INT;

    SELECT TOP 1 @MaKH = MaKH FROM DELETED; -- Trường hợp xóa 1 hóa đơn, lấy 1 KH

    -- Gọi thủ tục cập nhật điểm và loại thẻ
    IF @MaKH IS NOT NULL
    BEGIN
        EXEC sp_CapNhatDiemVaLoaiThe @MaKH;
    END
END;
GO

--
