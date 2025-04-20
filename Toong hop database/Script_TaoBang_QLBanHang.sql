

-- TOÀN BỘ SCRIPT TẠO VIEW

-- View 1: Thông tin khách hàng và thẻ thành viên
CREATE VIEW v_TatCaKhachHang
AS
SELECT 
    KH.MaKH, KH.TenKH ,KH.NgaySinh, KH.SDT, KH.GioiTinh, KH.ThanhPho, KH.Quan, KH.Duong, KH.SoNha,
    TV.Masothe,  TV.Ngaycap, TV.DiemTichLuy, LTT.Tenloaithe, LTT.Dieukien
FROM 
    KHACH_HANG KH
LEFT JOIN 
    THE_THANH_VIEN TV ON KH.MaKH = TV.MaKH
LEFT JOIN 
    LOAI_THE_THANH_VIEN LTT ON TV.Maloaithe = LTT.Maloaithe;
GO

-- View 2: Danh sách mặt hàng
CREATE VIEW vw_DanhSachMatHang AS
SELECT MaSP, TenSP, DonGia, SLTonKho, MoTaChiTiet, DonViTinh, Size FROM MAT_HANG;
GO

-- View 3: Hóa đơn đã bán
CREATE OR ALTER VIEW vw_HoaDonDaBan AS
SELECT 
    M.MaHD, M.NgayGiaoDich, KH.MaKH, KH.TenKH, M.TongTien,
    LTV.Tenloaithe, TV.DiemTichLuy
FROM MUA M
JOIN KHACH_HANG KH ON M.MaKH = KH.MaKH
LEFT JOIN THE_THANH_VIEN TV ON KH.MaKH = TV.MaKH
LEFT JOIN LOAI_THE_THANH_VIEN LTV ON TV.Maloaithe = LTV.Maloaithe;
GO

-- View 4: Tất cả sản phẩm kèm loại
CREATE OR ALTER VIEW v_TatCaSanPham AS
SELECT 
    MH.MaSP, MH.TenSP, MH.DonGia, MH.SLTonKho, MH.DonViTinh, MH.Size,
    MH.MoTaChiTiet, MH.MaLoai, LMH.TenLoai AS LoaiSanPham, LMH.CongDung
FROM MAT_HANG MH
JOIN LOAI_MAT_HANG LMH ON MH.MaLoai = LMH.MaLoai;
GO

-- View 5: Nhà cung ứng đầy đủ địa chỉ
CREATE OR ALTER VIEW vw_TatCaNhaCungUng AS
SELECT 
    MaNCU, TenNCU, SDT, Email,
    CONCAT(SoNha, ', ', Duong, ', ', Quan, ', ', ThanhPho) AS DiaChiDayDu
FROM NHA_CUNG_UNG;
GO

-- View 6: Hóa đơn nhập
CREATE OR ALTER VIEW vw_DanhSachHoaDonNhap AS
SELECT 
    N.MaHDN, N.NgayDat, N.TongTien, NCU.MaNCU, NCU.TenNCU, NCU.SDT
FROM NHAP N
JOIN NHA_CUNG_UNG NCU ON N.MaNCU = NCU.MaNCU;
GO

-- View 7: Top 3 sản phẩm bán chạy
CREATE OR ALTER VIEW vw_Top3SanPhamBanChay AS
SELECT TOP 3 MH.TenSP, SUM(CTM.SoLuong) AS SoLuongBan
FROM CHI_TIET_MUA CTM
JOIN MUA M ON CTM.MaHD = M.MaHD
JOIN MAT_HANG MH ON CTM.MaSP = MH.MaSP
WHERE M.NgayGiaoDich >= DATEADD(DAY, -7, GETDATE())
GROUP BY MH.TenSP
ORDER BY SoLuongBan DESC;
GO

-- View 8: Sản phẩm sắp hết hàng
CREATE OR ALTER VIEW vw_SanPhamSapHetHang AS
SELECT TOP 100 PERCENT MaSP, TenSP, SLTonKho
FROM MAT_HANG
WHERE SLTonKho <= 10
ORDER BY SLTonKho ASC;
GO

-- View 9: Tỷ lệ doanh thu theo loại
CREATE OR ALTER VIEW vw_TyLeDoanhThuTheoLoai AS
SELECT 
    LMH.TenLoai,
    SUM(
        CTM.SoLuong * MH.DonGia *
        (1 - ISNULL(CTM.ChietKhau, 0)/100.0) *
        (1 + ISNULL(CTM.VAT, 0)/100.0)
    ) AS DoanhThu
FROM CHI_TIET_MUA CTM
JOIN MAT_HANG MH ON CTM.MaSP = MH.MaSP
JOIN LOAI_MAT_HANG LMH ON MH.MaLoai = LMH.MaLoai
GROUP BY LMH.TenLoai;
GO

-- View 10: Sản phẩm bán chậm
CREATE OR ALTER VIEW vw_SanPhamBanCham AS
SELECT MH.MaSP, MH.TenSP, MH.SLTonKho
FROM MAT_HANG MH
WHERE NOT EXISTS (
    SELECT 1
    FROM CHI_TIET_MUA CTM
    JOIN MUA M ON CTM.MaHD = M.MaHD
    WHERE CTM.MaSP = MH.MaSP AND M.NgayGiaoDich >= DATEADD(DAY, -7, GETDATE())
);
GO

-- View 11: Danh sách nhà cung ứng (đơn giản)
CREATE OR ALTER VIEW vw_DanhSachNhaCungUng AS
SELECT MaNCU, TenNCU, SDT, Email, ThanhPho, Quan, Duong, SoNha
FROM NHA_CUNG_UNG;
GO

-- View 12: Danh sách nhân viên kèm nhóm người dùng
CREATE VIEW vw_NhanVien AS
SELECT 
    NV.MaNV, NV.TenNV, NV.NgaySinh, NV.SDT, NV.GioiTinh,
    NV.ThanhPho, NV.Quan, NV.Duong, NV.SoNha,
    NV.MaNND, NND.TenNND
FROM NHAN_VIEN NV
JOIN NHOM_NGUOI_DUNG NND ON NV.MaNND = NND.MaNND;
GO
-- Kết thúc tạo view    
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


CREATE OR ALTER TRIGGER trg_XoaHoaDonVaChiTietMua
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

-- trigger kiem tra ma loai co hop le khong khi them san pham moi 
CREATE OR ALTER TRIGGER trg_KiemTraMaLoaiSanPham
ON MAT_HANG
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra mã loại không tồn tại
    IF EXISTS (
        SELECT 1
        FROM INSERTED i
        WHERE NOT EXISTS (
            SELECT 1 FROM LOAI_MAT_HANG l WHERE l.MaLoai = i.MaLoai
        )
    )
    BEGIN
        RAISERROR(N'❌ Mã loại sản phẩm không tồn tại. Vui lòng kiểm tra lại!', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Nếu hợp lệ thì thực hiện thêm
    INSERT INTO MAT_HANG (TenSP, DonGia, SLTonKho, MoTaChiTiet, DonViTinh, Size, MaLoai)
    SELECT TenSP, DonGia, SLTonKho, MoTaChiTiet, DonViTinh, Size, MaLoai
    FROM INSERTED;
END;
GO
-- trigger Dưới đây là phiên bản trigger tổng quát để ngăn xóa sản phẩm (MaSP) nếu đã từng được dùng ở bất kỳ bảng liên quan nào
CREATE OR ALTER TRIGGER trg_PreventDeleteSanPhamLienKet
ON MAT_HANG
INSTEAD OF DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra nếu tồn tại trong chi tiết hóa đơn mua
    IF EXISTS (
        SELECT 1 FROM CHI_TIET_MUA CTM
        JOIN DELETED D ON CTM.MaSP = D.MaSP
    )
    BEGIN
        RAISERROR(N'❌ Không thể xóa: Sản phẩm đã có trong hóa đơn bán.', 16, 1);
        ROLLBACK;
        RETURN;
    END

    -- Kiểm tra nếu tồn tại trong chi tiết hóa đơn nhập
    IF EXISTS (
        SELECT 1 FROM CHI_TIET_NHAP CTN
        JOIN DELETED D ON CTN.MaSP = D.MaSP
    )
    BEGIN
        RAISERROR(N'❌ Không thể xóa: Sản phẩm đã có trong hóa đơn nhập.', 16, 1);
        ROLLBACK;
        RETURN;
    END

    -- Nếu không có ràng buộc thì xóa bình thường
    DELETE FROM MAT_HANG WHERE MaSP IN (SELECT MaSP FROM DELETED);
END;
GO
-- trigger cập nhật tổng tiền của 1 hdn khi có sự thay đổi ở chi tiết nhập   
CREATE OR ALTER TRIGGER trg_UpdateTongTienNhap
ON CHI_TIET_NHAP
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- Tập hợp các MaHDN bị ảnh hưởng
    DECLARE @MaHDNs TABLE (MaHDN INT);

    INSERT INTO @MaHDNs(MaHDN)
    SELECT MaHDN FROM inserted
    UNION
    SELECT MaHDN FROM deleted;

    -- Cập nhật tổng tiền lại cho từng hóa đơn
    UPDATE N
    SET TongTien = ISNULL((
        SELECT SUM(
            CTN.SoLuong * MH.DonGia
            * (1 - ISNULL(CTN.ChietKhau, 0) / 100.0)
            * (1 + ISNULL(CTN.VAT, 0) / 100.0)
        )
        FROM CHI_TIET_NHAP CTN
        JOIN MAT_HANG MH ON CTN.MaSP = MH.MaSP
        WHERE CTN.MaHDN = N.MaHDN
    ), 0)
    FROM NHAP N
    INNER JOIN @MaHDNs T ON N.MaHDN = T.MaHDN;
END;
GO
-- trigger cap nhat tong tien khi thay doi gia thanh mat hang o bang mat hang 
CREATE OR ALTER TRIGGER trg_CapNhatTongTienKhiDonGiaThayDoi
ON MAT_HANG
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Chỉ xử lý nếu có cập nhật DonGia
    IF UPDATE(DonGia)
    BEGIN
        -- Tập hợp các MaHDN bị ảnh hưởng từ CHI_TIET_NHAP có sản phẩm vừa được cập nhật
        DECLARE @MaHDNs TABLE (MaHDN INT);

        INSERT INTO @MaHDNs(MaHDN)
        SELECT DISTINCT CTN.MaHDN
        FROM CHI_TIET_NHAP CTN
        JOIN INSERTED I ON CTN.MaSP = I.MaSP;

        -- Cập nhật lại TongTien cho từng MaHDN
        UPDATE N
        SET TongTien = ISNULL((
            SELECT SUM(
                CTN.SoLuong * MH.DonGia *
                (1 - ISNULL(CTN.ChietKhau, 0) / 100.0) *
                (1 + ISNULL(CTN.VAT, 0) / 100.0)
            )
            FROM CHI_TIET_NHAP CTN
            JOIN MAT_HANG MH ON CTN.MaSP = MH.MaSP
            WHERE CTN.MaHDN = N.MaHDN
        ), 0)
        FROM NHAP N
        JOIN @MaHDNs T ON N.MaHDN = T.MaHDN;
    END
END;
GO
CREATE OR ALTER TRIGGER trg_TaoTaiKhoan_UngDung
ON NHAN_VIEN
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO DANG_NHAP (MaNV, Tentaikhoan, Matkhau)
    SELECT MaNV, 'user' + CAST(MaNV AS NVARCHAR), '123456'
    FROM INSERTED;
END;
GO  
CREATE OR ALTER TRIGGER trg_XoaTaiKhoan_UngDung
ON NHAN_VIEN
AFTER DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM DANG_NHAP
    WHERE MaNV IN (SELECT MaNV FROM DELETED);
END;
GO 
-- trigger 
CREATE   TRIGGER trg_TinhTongTienVaCapNhatHangThanhVien
ON CHI_TIET_MUA
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    -- B1: Xác định danh sách khách hàng bị ảnh hưởng
    DECLARE @MaKHs TABLE (MaKH INT);

    INSERT INTO @MaKHs (MaKH)
    SELECT DISTINCT M.MaKH
    FROM MUA M
    JOIN INSERTED I ON M.MaHD = I.MaHD
    UNION
    SELECT DISTINCT M.MaKH
    FROM MUA M
    JOIN DELETED D ON M.MaHD = D.MaHD;

    -- B2: Tính lại tổng tiền toàn bộ đơn hàng của từng KH
    DECLARE @MaKH INT, @TongChiTieu DECIMAL(18,2), @TongDiem INT, @LoaiThe INT;

    DECLARE cur CURSOR FOR
        SELECT MaKH FROM @MaKHs;

    OPEN cur;
    FETCH NEXT FROM cur INTO @MaKH;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Tổng tiền toàn bộ hóa đơn
        SELECT @TongChiTieu = SUM(TongTien)
        FROM MUA
        WHERE MaKH = @MaKH;

        -- Tính điểm theo tổng chi tiêu:
        SET @TongDiem = 
            CASE 
                WHEN @TongChiTieu < 300000 THEN 0
                WHEN @TongChiTieu BETWEEN 300000 AND 1000000 THEN 2
                WHEN @TongChiTieu BETWEEN 1000001 AND 2000000 THEN 6
                WHEN @TongChiTieu BETWEEN 2000001 AND 6000000 THEN 15
                WHEN @TongChiTieu > 6000000 THEN 30
            END;

        -- Cập nhật điểm tích lũy
        UPDATE THE_THANH_VIEN
        SET DiemTichLuy = @TongDiem
        WHERE MaKH = @MaKH;

        -- Tính lại cấp độ thẻ theo điểm
        SELECT TOP 1 @LoaiThe = Maloaithe
        FROM LOAI_THE_THANH_VIEN
        WHERE 
            (@TongDiem BETWEEN 10 AND 23 AND Tenloaithe = N'Bạc') OR
            (@TongDiem BETWEEN 24 AND 49 AND Tenloaithe = N'Vàng') OR
            (@TongDiem BETWEEN 50 AND 80 AND Tenloaithe = N'Bạch Kim') OR
            (@TongDiem > 80 AND Tenloaithe = N'Kim Cương')
        ORDER BY Maloaithe;

        -- Cập nhật loại thẻ
        IF @LoaiThe IS NOT NULL
        BEGIN
            UPDATE THE_THANH_VIEN
            SET Maloaithe = @LoaiThe
            WHERE MaKH = @MaKH;
        END

        FETCH NEXT FROM cur INTO @MaKH;
    END

    CLOSE cur;
    DEALLOCATE cur;
END;
GO  
-- ket thuc trigger  

-- trả về 1 nếu tài khoản và mật khẩu hợp lệ, 0 nếu không hợp lệ 
-- Tạo hàm kiểm tra tài khoản và mật khẩu   tham số đầu vào là Tentaikhoan, Matkhau
CREATE FUNCTION fn_KiemTraDangNhap
(
    @Tentaikhoan NVARCHAR(100),
    @Matkhau NVARCHAR(100)
)
RETURNS BIT
AS
BEGIN
    DECLARE @KetQua BIT;

    IF EXISTS (
        SELECT 1
        FROM DANG_NHAP
        WHERE Tentaikhoan = @Tentaikhoan AND Matkhau = @Matkhau
    )
        SET @KetQua = 1;
    ELSE
        SET @KetQua = 0;

    RETURN @KetQua;
END;
-- hàm  không có tham số đầu vào trả về MaNNDMaNND
GO
CREATE FUNCTION fn_GetMaNND
(
    @Tentaikhoan NVARCHAR(100),
    @Matkhau NVARCHAR(100)
)
RETURNS INT
AS
BEGIN
    DECLARE @MaNND INT;

    SELECT @MaNND = NV.MaNND
    FROM DANG_NHAP DN
    JOIN NHAN_VIEN NV ON DN.MaNV = NV.MaNV
    WHERE DN.Tentaikhoan = @Tentaikhoan AND DN.Matkhau = @Matkhau;

    RETURN @MaNND;
END;
GO
-- thu tuc them mot khach hang moi 
CREATE PROCEDURE sp_ThemKhachHang
    @TenKH NVARCHAR(100),
    @NgaySinh DATE,
    @SDT NVARCHAR(15),
    @GioiTinh NVARCHAR(10),
    @ThanhPho NVARCHAR(50),
    @Quan NVARCHAR(50),
    @Duong NVARCHAR(50),
    @SoNha NVARCHAR(20)
AS
BEGIN
    INSERT INTO KHACH_HANG (TenKH, NgaySinh, SDT, GioiTinh, ThanhPho, Quan, Duong, SoNha)
    VALUES (@TenKH, @NgaySinh, @SDT, @GioiTinh, @ThanhPho, @Quan, @Duong, @SoNha)
END;
GO
-- sua thong tin mot khach hang
CREATE PROCEDURE sp_CapNhatKhachHang
    @MaKH INT,
    @TenKH NVARCHAR(100),
    @NgaySinh DATE,
    @SDT NVARCHAR(15),
    @GioiTinh NVARCHAR(10),
    @ThanhPho NVARCHAR(50),
    @Quan NVARCHAR(50),
    @Duong NVARCHAR(50),
    @SoNha NVARCHAR(20)
AS
BEGIN
    UPDATE KHACH_HANG
    SET TenKH = @TenKH,
        NgaySinh = @NgaySinh,
        SDT = @SDT,
        GioiTinh = @GioiTinh,
        ThanhPho = @ThanhPho,
        Quan = @Quan,
        Duong = @Duong,
        SoNha = @SoNha
    WHERE MaKH = @MaKH
END;
GO
-- thu tuc xoa khach hang co tham so la MaKH 
CREATE PROCEDURE sp_XoaKhachHang
    @MaKH INT
AS
BEGIN
    -- Xóa thẻ thành viên nếu có
    DELETE FROM THE_THANH_VIEN WHERE MaKH = @MaKH;

    -- Xóa khách hàng (nếu trigger cho phép)
    DELETE FROM KHACH_HANG WHERE MaKH = @MaKH;
END;
GO


    -- ===============================================
    -- THỦ TỤC: sp_TimKiemKhachHangNhanh
    -- Loại: Stored Procedure
    -- Tham số: Có (@TuKhoa NVARCHAR)
    -- Trả về: Bảng (SELECT)
    -- Mục đích: Tìm kiếm khách hàng theo tên, SDT hoặc mã
    -- ===============================================
ALTER PROCEDURE sp_TimKiemKhachHangNhanh
    @TuKhoa NVARCHAR(100)
AS
BEGIN
    SELECT 
        KH.MaKH,
        KH.TenKH,
        KH.SDT,
        KH.ThanhPho,
        KH.Quan,
        KH.Duong,
        KH.SoNha,
        TV.DiemTichLuy
    FROM KHACH_HANG KH
    LEFT JOIN THE_THANH_VIEN TV ON KH.MaKH = TV.MaKH
    WHERE 
        KH.TenKH LIKE '%' + @TuKhoa + '%' OR
        KH.SDT LIKE '%' + @TuKhoa + '%' OR
        CAST(KH.MaKH AS NVARCHAR) LIKE '%' + @TuKhoa + '%';
END;
GO
-- thu tuc them 1 hoa don moi 
CREATE OR ALTER PROCEDURE sp_TaoHoaDon
    @MaKH INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaHD INT;

    INSERT INTO MUA (NgayGiaoDich, MAKH, TongTien)
    VALUES (CAST(GETDATE() AS DATE), @MaKH, 0);

    SET @MaHD = SCOPE_IDENTITY();

    SELECT @MaHD AS MaHD; -- Trả về mã hóa đơn vừa tạo
END;
GO

-- thu tuc hien thi chi tiet mot hoa don tra ve 1 bang voi tham so la mahd 
CREATE OR ALTER PROCEDURE sp_LayChiTietHoaDon
    @MaHD INT
AS
BEGIN
    SELECT 
        mh.MaSP,
        mh.TenSP,
        ctm.SoLuong,
        mh.DonGia,
        ISNULL(ctm.VAT, 0) AS VAT,
        ISNULL(ctm.Chietkhau, 0) AS ChietKhau,
        (mh.DonGia * ctm.SoLuong * 
         (1 - ISNULL(ctm.Chietkhau, 0) / 100.0) * 
         (1 + ISNULL(ctm.VAT, 0) / 100.0)) AS ThanhTien
    FROM CHI_TIET_MUA ctm
    JOIN MAT_HANG mh ON ctm.MaSP = mh.MaSP
    WHERE ctm.MaHD = @MaHD;
END;
GO
-- thủ tục lấy mã loại sản phẩm và tên sản phẩm 
CREATE OR ALTER PROCEDURE sp_LayLoaiSanPham
AS
BEGIN
    SELECT MaLoai, TenLoai FROM LOAI_MAT_HANG;
END;
GO
-- thủ tục lọc sản phẩm theo loại sản phẩm 
CREATE OR ALTER PROCEDURE sp_LaySanPhamTheoLoai
    @MaLoai INT
AS
BEGIN
    SELECT 
        MaSP, TenSP, DonGia, SLTonKho, MoTaChiTiet, DonViTinh, Size
    FROM MAT_HANG
    WHERE MaLoai = @MaLoai;
END;
GO
-- thủ tục them chi tiết hóa đơn 
CREATE OR ALTER PROCEDURE sp_ThemChiTietHoaDon
    @MaHD INT,
    @MaSP INT,
    @SoLuong INT,
    @ChietKhau FLOAT = 0,
    @VAT FLOAT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Kiểm tra chiết khấu và VAT hợp lệ
    IF (@ChietKhau > 100 OR @VAT > 100)
    BEGIN
        RAISERROR(N'VAT hoặc Chiết khấu không được vượt quá 100%.', 16, 1);
        RETURN;
    END

    -- 2. Lấy tồn kho hiện tại
    DECLARE @TonKho INT;
    SELECT @TonKho = SLTonKho FROM MAT_HANG WHERE MaSP = @MaSP;

    -- 3. Kiểm tra tồn kho đủ
    IF (@TonKho IS NULL OR @TonKho < @SoLuong)
    BEGIN
        RAISERROR(N'Tồn kho không đủ để thêm sản phẩm vào hóa đơn.', 16, 1);
        RETURN;
    END

    -- 4. Thêm vào chi tiết hóa đơn
    INSERT INTO CHI_TIET_MUA (MaHD, MaSP, SoLuong, ChietKhau, VAT)
    VALUES (@MaHD, @MaSP, @SoLuong, @ChietKhau, @VAT);

    -- 5. Trừ tồn kho
    UPDATE MAT_HANG
    SET SLTonKho = SLTonKho - @SoLuong
    WHERE MaSP = @MaSP;
END;
GO

GO
-- thu tuc co tham so cap nhat chi tiet hoa don 
CREATE OR ALTER PROCEDURE sp_SuaChiTietHoaDon
    @MaHD INT,
    @MaSP INT,
    @SoLuong INT,
    @ChietKhau FLOAT,
    @VAT FLOAT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra VAT hoặc ChiếtKhau vượt quá 100%
    IF (@VAT > 100 OR @ChietKhau > 100)
    BEGIN
        RAISERROR(N'VAT hoặc Chiết khấu không được vượt quá 100%.', 16, 1);
        RETURN;
    END

    -- Lấy số lượng tồn kho hiện tại & số lượng cũ
    DECLARE @TonKhoHienTai INT, @SoLuongCu INT;
    SELECT @TonKhoHienTai = SLTonKho FROM MAT_HANG WHERE MaSP = @MaSP;
    SELECT @SoLuongCu = SoLuong FROM CHI_TIET_MUA WHERE MaHD = @MaHD AND MaSP = @MaSP;

    DECLARE @Chenhlech INT = @SoLuong - ISNULL(@SoLuongCu, 0);

    -- Kiểm tra tồn kho đủ không
    IF (@Chenhlech > @TonKhoHienTai)
    BEGIN
        RAISERROR(N'Tồn kho không đủ để cập nhật số lượng sản phẩm.', 16, 1);
        RETURN;
    END

    -- Cập nhật chi tiết hóa đơn
    UPDATE CHI_TIET_MUA
    SET SoLuong = @SoLuong,
        ChietKhau = @ChietKhau,
        VAT = @VAT
    WHERE MaHD = @MaHD AND MaSP = @MaSP;

    -- Cập nhật tồn kho theo chênh lệch
    UPDATE MAT_HANG
    SET SLTonKho = SLTonKho - @Chenhlech
    WHERE MaSP = @MaSP;
END;
GO

-- thu tuc  xoa mot  sản phẩm ở chi tiết hóa đơn 




CREATE OR ALTER PROCEDURE sp_XoaChiTietHoaDon
    @MaHD INT,
    @MaSP INT
AS
BEGIN
    DECLARE @SoLuong INT;

    -- Lấy số lượng cần trả lại
    SELECT @SoLuong = SoLuong FROM CHI_TIET_MUA WHERE MaHD = @MaHD AND MaSP = @MaSP;

    -- Trả lại tồn kho
    UPDATE MAT_HANG
    SET SLTonKho = SLTonKho + @SoLuong
    WHERE MaSP = @MaSP;

    -- Xoá chi tiết hóa đơn
    DELETE FROM CHI_TIET_MUA WHERE MaHD = @MaHD AND MaSP = @MaSP;
END;
GO

-- thủ tục tìm kiếm tên, sdt khách hàng quà ID ---------------------------------------------


CREATE OR ALTER PROCEDURE sp_TimKhachHangTheoID
    @MaKH INT
AS
BEGIN
    SELECT TenKH, SDT FROM KHACH_HANG WHERE MaKH = @MaKH;
END
GO  
-- lấy tổng tiền từ một hóa đơn của khách hàng 
CREATE OR ALTER FUNCTION fn_TongTienTheoKHVaHD
(
    @MaKH INT,
    @MaHD INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
    DECLARE @TongTien DECIMAL(18,2)

    SELECT @TongTien = TongTien
    FROM MUA
    WHERE MaKH = @MaKH AND MaHD = @MaHD;

    RETURN ISNULL(@TongTien, 0);
END;
GO
-- thủ tục cập nhật điẻm tích lũy hạng cho khách hang sau khi xóa 
CREATE OR ALTER PROCEDURE sp_CapNhatDiemVaLoaiThe
    @MaKH INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TongDiem INT = 0, @TmpTongTien DECIMAL(18,2), @Diem INT;

    DECLARE cur CURSOR FOR
        SELECT TongTien FROM MUA WHERE MaKH = @MaKH;

    OPEN cur;
    FETCH NEXT FROM cur INTO @TmpTongTien;

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

        FETCH NEXT FROM cur INTO @TmpTongTien;
    END

    CLOSE cur;
    DEALLOCATE cur;

    -- Cập nhật điểm tích lũy
    UPDATE THE_THANH_VIEN
    SET DiemTichLuy = @TongDiem
    WHERE MaKH = @MaKH;

    -- Cập nhật loại thẻ tương ứng
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
END;
GO
-- thủ tục timf kiem hoa don thong qua tu khoa (co the la ten khach hang sdt )
CREATE OR ALTER FUNCTION fn_TimHoaDonTheoKH (@TuKhoa NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        M.MaHD,
        M.NgayGiaoDich,
        KH.MaKH,
        KH.TenKH,
        KH.SDT,
        M.TongTien,
        LTV.Tenloaithe,
        TV.DiemTichLuy
    FROM MUA M
    JOIN KHACH_HANG KH ON M.MaKH = KH.MaKH
    LEFT JOIN THE_THANH_VIEN TV ON KH.MaKH = TV.MaKH
    LEFT JOIN LOAI_THE_THANH_VIEN LTV ON TV.Maloaithe = LTV.Maloaithe
    WHERE 
        KH.TenKH LIKE N'%' + @TuKhoa + '%' OR
        KH.SDT LIKE N'%' + @TuKhoa + '%'
);
-- thu tuc xoa hoa don dua tren MaHD 
CREATE OR ALTER PROCEDURE sp_XoaHoaDon
    @MaHD INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaKH INT;

    -- Lấy MaKH để cập nhật lại điểm sau khi xóa
    SELECT @MaKH = MaKH FROM MUA WHERE MaHD = @MaHD;

    -- Xóa chi tiết hóa đơn trước
    DELETE FROM CHI_TIET_MUA WHERE MaHD = @MaHD;

    -- Xóa hóa đơn
    DELETE FROM MUA WHERE MaHD = @MaHD;

    -- Cập nhật điểm và loại thẻ
    IF @MaKH IS NOT NULL
        EXEC sp_CapNhatDiemVaLoaiThe @MaKH;
END;
GO
-- thu tuc lay chi tiet hoa don tu mahd va makh 
CREATE OR ALTER PROCEDURE sp_LayChiTietHoaDonTheoKH
    @MaHD INT,
    @MaKH INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Chỉ lấy chi tiết hóa đơn nếu đúng là của khách hàng đó
    IF EXISTS (SELECT 1 FROM MUA WHERE MaHD = @MaHD AND MaKH = @MaKH)
    BEGIN
        SELECT 
            mh.MaSP,
            mh.TenSP,
            ctm.SoLuong,
            mh.DonGia,
            ISNULL(ctm.VAT, 0) AS VAT,
            ISNULL(ctm.Chietkhau, 0) AS ChietKhau,
            (mh.DonGia * ctm.SoLuong * 
             (1 - ISNULL(ctm.Chietkhau, 0) / 100.0) * 
             (1 + ISNULL(ctm.VAT, 0) / 100.0)) AS ThanhTien
        FROM CHI_TIET_MUA ctm
        JOIN MAT_HANG mh ON ctm.MaSP = mh.MaSP
        WHERE ctm.MaHD = @MaHD;
    END
    ELSE
    BEGIN
        RAISERROR(N'Hóa đơn không thuộc khách hàng này.', 16, 1);
    END
END;
GO
-- ham thu tuc xem co them mot san pham moi 
CREATE OR ALTER PROCEDURE sp_ThemSanPham
    @TenSP NVARCHAR(100),
    @DonGia DECIMAL(18,2),
    @SLTonKho INT,
    @DonViTinh NVARCHAR(20),
    @Size NVARCHAR(20),
    @MoTaChiTiet NVARCHAR(MAX),
    @MaLoai INT
AS
BEGIN
    INSERT INTO MAT_HANG (TenSP, DonGia, SLTonKho, DonViTinh, Size, MoTaChiTiet, MaLoai)
    VALUES (@TenSP, @DonGia, @SLTonKho, @DonViTinh, @Size, @MoTaChiTiet, @MaLoai);
END
GO
-- thủ tục cập nhật sản phẩm 
CREATE OR ALTER PROCEDURE sp_CapNhatSanPham
    @MaSP INT,
    @TenSP NVARCHAR(100),
    @DonGia DECIMAL(18, 2),
    @SLTonKho INT,
    @DonViTinh NVARCHAR(20),
    @Size NVARCHAR(20),
    @MoTaChiTiet NVARCHAR(MAX),
    @MaLoai INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Kiểm tra mã loại có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM LOAI_MAT_HANG WHERE MaLoai = @MaLoai)
    BEGIN
        RAISERROR(N'❌ Mã loại sản phẩm không tồn tại.', 16, 1);
        RETURN;
    END

    -- Cập nhật thông tin sản phẩm
    UPDATE MAT_HANG
    SET 
        TenSP = @TenSP,
        DonGia = @DonGia,
        SLTonKho = @SLTonKho,
        DonViTinh = @DonViTinh,
        Size = @Size,
        MoTaChiTiet = @MoTaChiTiet,
        MaLoai = @MaLoai
    WHERE MaSP = @MaSP;
END;
GO
-- thủ tục xóa sản phẩm 
CREATE OR ALTER PROCEDURE sp_XoaSanPham
    @MaSP INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Xóa sản phẩm (Trigger sẽ tự kiểm tra nếu sản phẩm liên kết với bảng khác)
    DELETE FROM MAT_HANG WHERE MaSP = @MaSP;
END;
GO

-- tao hóa hóa đơn nhập  qua mã nhà cung ứng 
CREATE OR ALTER PROCEDURE sp_TaoPhieuNhap
    @MaNCU INT,
    @NgayDat DATE = NULL -- cho phép truyền hoặc để mặc định theo thời gian thực
AS
BEGIN
    SET NOCOUNT ON;

    IF @NgayDat IS NULL
        SET @NgayDat = CAST(GETDATE() AS DATE); -- Dùng ngày hiện tại nếu không truyền vào

    INSERT INTO NHAP (NgayDat, TongTien, MaNCU)
    VALUES (@NgayDat, 0, @MaNCU);

    -- Trả về mã phiếu nhập mới
    SELECT SCOPE_IDENTITY() AS MaHDN;
END;
-- hàm tạo lấy thông tin nhà cung ứng qua mahdnn
CREATE OR ALTER FUNCTION fn_LayThongTinPhieuNhap(@MaHDN INT)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        N.MaHDN,
        N.NgayDat,
        NCU.MaNCU,
        NCU.TenNCU,
        NCU.SDT
    FROM NHAP N
    JOIN NHA_CUNG_UNG NCU ON N.MaNCU = NCU.MaNCU
    WHERE N.MaHDN = @MaHDN
);


-- lấy chi tiết hoa don nhap 
CREATE OR ALTER PROCEDURE sp_LayChiTietNhapTheoHDN
    @MaHDN INT
AS
BEGIN
    SELECT 
        MH.MaSP,
        MH.TenSP,
        CTN.SoLuong,
        MH.DonGia,
        ISNULL(CTN.VAT, 0) AS VAT,
        ISNULL(CTN.ChietKhau, 0) AS ChietKhau,
        (MH.DonGia * CTN.SoLuong * 
         (1 - ISNULL(CTN.ChietKhau, 0) / 100.0) * 
         (1 + ISNULL(CTN.VAT, 0) / 100.0)) AS ThanhTien
    FROM CHI_TIET_NHAP CTN
    JOIN MAT_HANG MH ON CTN.MaSP = MH.MaSP
    WHERE CTN.MaHDN = @MaHDN;
END;
GO
--- thu tuc them chi tiet hoa don nhap   
CREATE OR ALTER PROCEDURE sp_ThemChiTietNhap
    @MaHDN INT,
    @MaSP INT,
    @SoLuong INT,
    @ChietKhau FLOAT = 0,
    @VAT FLOAT = 0
AS
BEGIN
    SET NOCOUNT ON;

    IF @SoLuong <= 0 OR @VAT > 100 OR @ChietKhau > 100
    BEGIN
        RAISERROR(N'Dữ liệu không hợp lệ.', 16, 1);
        RETURN;
    END

    INSERT INTO CHI_TIET_NHAP (MaHDN, MaSP, SoLuong, ChietKhau, VAT)
    VALUES (@MaHDN, @MaSP, @SoLuong, @ChietKhau, @VAT);

    UPDATE MAT_HANG
    SET SLTonKho = SLTonKho + @SoLuong
    WHERE MaSP = @MaSP;
END;
-- sua chi tiết nhập 
CREATE OR ALTER PROCEDURE sp_SuaChiTietNhap
    @MaHDN INT,
    @MaSP INT,
    @SoLuong INT,
    @ChietKhau FLOAT,
    @VAT FLOAT
AS
BEGIN
    SET NOCOUNT ON;

    IF @SoLuong <= 0 OR @ChietKhau > 100 OR @VAT > 100
    BEGIN
        RAISERROR(N'Dữ liệu không hợp lệ.', 16, 1);
        RETURN;
    END

    -- 1. Lấy số lượng cũ
    DECLARE @SoLuongCu INT;

    SELECT @SoLuongCu = SoLuong
    FROM CHI_TIET_NHAP
    WHERE MaHDN = @MaHDN AND MaSP = @MaSP;

    IF @SoLuongCu IS NULL
    BEGIN
        RAISERROR(N'Dữ liệu chi tiết nhập không tồn tại.', 16, 1);
        RETURN;
    END

    -- 2. Tính chênh lệch
    DECLARE @ChenhLech INT = @SoLuong - @SoLuongCu;

    -- 3. Cập nhật số lượng chi tiết
    UPDATE CHI_TIET_NHAP
    SET SoLuong = @SoLuong,
        ChietKhau = @ChietKhau,
        VAT = @VAT
    WHERE MaHDN = @MaHDN AND MaSP = @MaSP;

    -- 4. Cập nhật tồn kho
    UPDATE MAT_HANG
    SET SLTonKho = SLTonKho + @ChenhLech
    WHERE MaSP = @MaSP;
END;


-- sp xoa san pham trong chi tiet nhap 
CREATE OR ALTER PROCEDURE sp_XoaChiTietNhap
    @MaHDN INT,
    @MaSP INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @SoLuong INT;

    -- 1. Lấy số lượng nhập để trừ tồn kho
    SELECT @SoLuong = SoLuong
    FROM CHI_TIET_NHAP
    WHERE MaHDN = @MaHDN AND MaSP = @MaSP;

    IF @SoLuong IS NULL
    BEGIN
        RAISERROR(N'❌ Không tìm thấy chi tiết nhập để xóa.', 16, 1);
        RETURN;
    END

    -- 2. Trừ tồn kho trực tiếp
    UPDATE MAT_HANG
    SET SLTonKho = SLTonKho - @SoLuong
    WHERE MaSP = @MaSP;

    -- 3. Xóa chi tiết nhập
    DELETE FROM CHI_TIET_NHAP
    WHERE MaHDN = @MaHDN AND MaSP = @MaSP;
END;
--- ham tim kiem hoa don nhap theo tu khoa   
CREATE OR ALTER FUNCTION fn_TimKiemPhieuNhap
(
    @TuKhoa NVARCHAR(100)
)
RETURNS TABLE
AS
RETURN
(
    SELECT 
        N.MaHDN,
        N.NgayDat,
        N.TongTien,
        NCU.MaNCU,
        NCU.TenNCU,
        NCU.SDT
    FROM NHAP N
    JOIN NHA_CUNG_UNG NCU ON N.MaNCU = NCU.MaNCU
    WHERE 
        -- Tìm theo mã hóa đơn
        CAST(N.MaHDN AS NVARCHAR) LIKE '%' + @TuKhoa + '%'
        OR 
        -- Tìm theo ngày (định dạng yyyy-mm-dd hoặc chỉ yyyy-mm)
        CONVERT(NVARCHAR, N.NgayDat, 120) LIKE '%' + @TuKhoa + '%'
        OR 
        -- Tên nhà cung ứng
        NCU.TenNCU LIKE '%' + @TuKhoa + '%'
        OR 
        -- SĐT nhà cung ứng
        NCU.SDT LIKE '%' + @TuKhoa + '%'    
    -- Bạn có thể thêm các trường khác nếu cần
);
GO
-- tim nha cung ung 
CREATE   FUNCTION fn_TimNhaCungUng (@TuKhoa NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT 
        MaNCU,
        TenNCU,
        SDT,
        Email,
        CONCAT(SoNha, ', ', Duong, ', ', Quan, ', ', ThanhPho) AS DiaChi
    FROM NHA_CUNG_UNG
    WHERE 
        TenNCU LIKE '%' + @TuKhoa + '%'
        OR SDT LIKE '%' + @TuKhoa + '%'
);
GO
-- ham khong tham so tra ve gia tri int 
CREATE OR ALTER FUNCTION fn_DoanhThuHomNay()
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TongTien DECIMAL(18,2)

    SELECT @TongTien = SUM(TongTien)
    FROM MUA
    WHERE NgayGiaoDich = CAST(GETDATE() AS DATE)

    RETURN ISNULL(@TongTien, 0)
END;
GO
CREATE OR ALTER FUNCTION fn_SoHoaDonHomNay()
RETURNS INT
AS
BEGIN
    DECLARE @SoHD INT

    SELECT @SoHD = COUNT(*)
    FROM MUA
    WHERE NgayGiaoDich = CAST(GETDATE() AS DATE)

    RETURN ISNULL(@SoHD, 0)
END;
GO
CREATE OR ALTER FUNCTION fn_TongSoKhachHang()
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM KHACH_HANG)
END;
GO
CREATE OR ALTER FUNCTION fn_SoLuongSanPhamSapHetHang()
RETURNS INT
AS
BEGIN
    DECLARE @SoLuong INT;

    SELECT @SoLuong = COUNT(*) 
    FROM MAT_HANG
    WHERE SLTonKho <= 10;

    RETURN ISNULL(@SoLuong, 0);
END;
GO 
-- thu tuc them nha cung ung 
CREATE OR ALTER PROCEDURE sp_ThemNhaCungUng
    @TenNCU NVARCHAR(100),
    @SDT NVARCHAR(15),
    @Email NVARCHAR(100),
    @ThanhPho NVARCHAR(50),
    @Quan NVARCHAR(50),
    @Duong NVARCHAR(50),
    @SoNha NVARCHAR(20)
AS
BEGIN
    -- Kiểm tra trùng Email
    IF EXISTS (SELECT 1 FROM NHA_CUNG_UNG WHERE Email = @Email)
    BEGIN
        RAISERROR(N'❌ Email đã tồn tại. Vui lòng dùng email khác.', 16, 1);
        RETURN;
    END

    -- Kiểm tra trùng SDT
    IF EXISTS (SELECT 1 FROM NHA_CUNG_UNG WHERE SDT = @SDT)
    BEGIN
        RAISERROR(N'❌ Số điện thoại đã tồn tại. Vui lòng dùng số khác.', 16, 1);
        RETURN;
    END

    -- Thêm mới nếu hợp lệ
    INSERT INTO NHA_CUNG_UNG (TenNCU, SDT, Email, ThanhPho, Quan, Duong, SoNha)
    VALUES (@TenNCU, @SDT, @Email, @ThanhPho, @Quan, @Duong, @SoNha);
END;
GO  
-- Thu tuc cap nhat nha cung ung 
CREATE OR ALTER PROCEDURE sp_CapNhatNhaCungUng
    @MaNCU INT,
    @TenNCU NVARCHAR(100),
    @SDT NVARCHAR(15),
    @Email NVARCHAR(100),
    @ThanhPho NVARCHAR(50),
    @Quan NVARCHAR(50),
    @Duong NVARCHAR(50),
    @SoNha NVARCHAR(20)
AS
BEGIN
    UPDATE NHA_CUNG_UNG
    SET TenNCU = @TenNCU,
        SDT = @SDT,
        Email = @Email,
        ThanhPho = @ThanhPho,
        Quan = @Quan,
        Duong = @Duong,
        SoNha = @SoNha
    WHERE MaNCU = @MaNCU
END;
GO 
-- ❌ 3. Xóa nhà cung ứng (kiểm tra nếu đã có phiếu nhập)
CREATE OR ALTER PROCEDURE sp_XoaNhaCungUng
    @MaNCU INT
AS
BEGIN
    IF EXISTS (SELECT 1 FROM NHAP WHERE MaNCU = @MaNCU)
    BEGIN
        RAISERROR(N'❌ Không thể xoá: Nhà cung ứng đã phát sinh nhập hàng.', 16, 1);
        RETURN;
    END

    DELETE FROM NHA_CUNG_UNG WHERE MaNCU = @MaNCU;
END;
GO 
-- ham tim kiem nha cung ung theo tu khoa 
CREATE OR ALTER PROCEDURE sp_TimNhaCungUngTheoTuKhoa
    @TuKhoa NVARCHAR(100)
AS
BEGIN
    SELECT * FROM NHA_CUNG_UNG
    WHERE 
        TenNCU LIKE '%' + @TuKhoa + '%' OR
        SDT LIKE '%' + @TuKhoa + '%' OR
        Email LIKE '%' + @TuKhoa + '%';
END;
GO  
-- thủ tục them nhan vien 
CREATE OR ALTER PROCEDURE sp_ThemNhanVien
    @MaNND INT,
    @TenNV NVARCHAR(100),
    @NgaySinh DATE,
    @SDT NVARCHAR(15),
    @GioiTinh NVARCHAR(10),
    @ThanhPho NVARCHAR(50),
    @Quan NVARCHAR(50),
    @Duong NVARCHAR(50),
    @SoNha NVARCHAR(20),
    @MaNV_Moi INT OUTPUT
AS
BEGIN
    INSERT INTO NHAN_VIEN (MaNND, TenNV, NgaySinh, SDT, GioiTinh, ThanhPho, Quan, Duong, SoNha)
    VALUES (@MaNND, @TenNV, @NgaySinh, @SDT, @GioiTinh, @ThanhPho, @Quan, @Duong, @SoNha);

    SET @MaNV_Moi = SCOPE_IDENTITY(); -- Trả về mã nhân viên vừa thêm
END
GO   
-- thu tuc cap nhat  nhan vien 
CREATE OR ALTER PROCEDURE sp_CapNhatNhanVien
    @MaNV INT,
    @MaNND INT,
    @TenNV NVARCHAR(100),
    @NgaySinh DATE,
    @SDT NVARCHAR(15),
    @GioiTinh NVARCHAR(10),
    @ThanhPho NVARCHAR(50),
    @Quan NVARCHAR(50),
    @Duong NVARCHAR(50),
    @SoNha NVARCHAR(20)
AS
BEGIN
    IF EXISTS (SELECT 1 FROM NHAN_VIEN WHERE SDT = @SDT AND MaNV != @MaNV)
    BEGIN
        RAISERROR(N'❌ SĐT đã tồn tại cho nhân viên khác!', 16, 1);
        RETURN;
    END

    UPDATE NHAN_VIEN
    SET MaNND = @MaNND,
        TenNV = @TenNV,
        NgaySinh = @NgaySinh,
        SDT = @SDT,
        GioiTinh = @GioiTinh,
        ThanhPho = @ThanhPho,
        Quan = @Quan,
        Duong = @Duong,
        SoNha = @SoNha
    WHERE MaNV = @MaNV;
END;
GO 
-- thu tuc xoa nhan vien 
CREATE OR ALTER PROCEDURE sp_XoaNhanVien
    @MaNV INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Xoá tài khoản ứng dụng trước (nếu có)
    DELETE FROM DANG_NHAP WHERE MaNV = @MaNV;

    -- Xoá nhân viên
    DELETE FROM NHAN_VIEN WHERE MaNV = @MaNV;
END


-- thu tuc tim kiem nhan vien 
CREATE OR ALTER FUNCTION fn_TimKiemNhanVien (@TuKhoa NVARCHAR(100))
RETURNS TABLE
AS
RETURN
(
    SELECT *
    FROM NHAN_VIEN
    WHERE 
        TenNV LIKE '%' + @TuKhoa + '%'
        OR SDT LIKE '%' + @TuKhoa + '%'
        OR CAST(MaNV AS NVARCHAR) LIKE '%' + @TuKhoa + '%'
);
-- thu tuc tao login cho nhan vien 
CREATE OR ALTER PROCEDURE sp_TaoLoginChoNhanVien
    @TenDangNhap NVARCHAR(100),
    @MatKhau NVARCHAR(100)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX)

    SET @SQL = '
    IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = ''' + @TenDangNhap + ''')
        CREATE LOGIN [' + @TenDangNhap + '] WITH PASSWORD = ''' + @MatKhau + ''';'
    EXEC (@SQL)

    SET @SQL = '
    USE [' + DB_NAME() + '];
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = ''' + @TenDangNhap + ''')
    BEGIN
        CREATE USER [' + @TenDangNhap + '] FOR LOGIN [' + @TenDangNhap + '];
        GRANT SELECT, INSERT, UPDATE, DELETE TO [' + @TenDangNhap + '];
    END'
    EXEC (@SQL)
END;
GO 

-- thu tuc xoa login 
CREATE OR ALTER PROCEDURE sp_XoaLoginNhanVien
    @TenDangNhap NVARCHAR(100)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);

    -- Xóa USER trong database nếu tồn tại
    SET @SQL = '
    IF EXISTS (SELECT * FROM sys.database_principals WHERE name = ''' + @TenDangNhap + ''')
        DROP USER [' + @TenDangNhap + ']';
    EXEC (@SQL);

    -- Xóa LOGIN nếu tồn tại
    SET @SQL = '
    IF EXISTS (SELECT * FROM sys.server_principals WHERE name = ''' + @TenDangNhap + ''')
        DROP LOGIN [' + @TenDangNhap + ']';
    EXEC (@SQL);
END;
GO   
-- thu tuc update tong tien theo loai the 
CREATE   PROCEDURE sp_UpdateTongTienTheoLoaiThe
    @MaKH INT,
    @MaHD INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @TongGoc DECIMAL(18,2);
    DECLARE @PhanTramGiam FLOAT = 0;
    DECLARE @TongSauGiam DECIMAL(18,2);

    -- 1. Lấy tổng tiền gốc đã được tính sẵn
    SELECT @TongGoc = TongTien
    FROM MUA
    WHERE MaHD = @MaHD AND MaKH = @MaKH;

    -- 2. Lấy phần trăm giảm từ thẻ thành viên
    SELECT @PhanTramGiam =
        CASE LTV.Tenloaithe
            WHEN N'Bạc' THEN 4
            WHEN N'Vàng' THEN 7
            WHEN N'Bạch Kim' THEN 9
            WHEN N'Kim Cương' THEN 12
            ELSE 0
        END
    FROM THE_THANH_VIEN TV
    JOIN LOAI_THE_THANH_VIEN LTV ON TV.Maloaithe = LTV.Maloaithe
    WHERE TV.MaKH = @MaKH;

    -- 3. Tính tổng tiền sau giảm
    SET @TongSauGiam = ISNULL(@TongGoc, 0) * (1 - @PhanTramGiam / 100.0);

    -- 4. Cập nhật vào bảng MUA
    UPDATE MUA
    SET TongTien = @TongSauGiam
    WHERE MaHD = @MaHD AND MaKH = @MaKH;
END;

GO  
-- ket thuc ham thu tuc 
-- Nhóm người dùng
INSERT INTO NHOM_NGUOI_DUNG (TenNND) VALUES
(N'Quản trị viên'),
(N'Nhân viên bán hàng'),
(N'Chủ cửa hàng'),
(N'Nhân viên nhập kho');

-- Quyền
INSERT INTO QUYEN (TenQuyen) VALUES
(N'Quản lý hệ thống'),
(N'Bán hàng'),
(N'Nhập kho'),
(N'Báo cáo doanh thu');

-- Nhân viên
INSERT INTO NHAN_VIEN (MaNND, TenNV, NgaySinh, SDT, GioiTinh, ThanhPho, Quan, Duong, SoNha) VALUES
(1, N'Lê Minh Quân', '1985-03-15', '0909123456', N'Nam', N'Hà Nội', N'Cầu Giấy', N'Trần Duy Hưng', '123'),
(2, N'Nguyễn Thị Hoa', '1990-07-22', '0909765432', N'Nữ', N'HCM', N'Tân Bình', N'Cộng Hòa', '45B'),
(3, N'Phạm Văn Khánh', '1982-02-10', '0911222333', N'Nam', N'Đà Nẵng', N'Hải Châu', N'Nguyễn Văn Linh', '56'),
(4, N'Hoàng Anh Tú', '1995-09-05', '0911333444', N'Nam', N'Cần Thơ', N'Ninh Kiều', N'Hòa Bình', '22');

-- Tài khoản đăng nhập
INSERT INTO DANG_NHAP (MaNV, Tentaikhoan, Matkhau) VALUES
(1, N'quanadmin', N'admin123'),
(2, N'hoasales', N'sales456'),
(3, N'khanhchu', N'owner789'),
(4, N'tukho', N'warehouse321');

-- Phân quyền
INSERT INTO PHANQUYEN (MaNND, MaQuyen, Mota) VALUES
(1, 1, N'Quyền truy cập toàn bộ hệ thống'),
(2, 2, N'Quyền bán hàng và tạo hóa đơn'),
(3, 4, N'Quyền xem báo cáo tổng hợp'),
(4, 3, N'Quyền nhập kho và kiểm kê hàng');

-- Khách hàng
INSERT INTO KHACH_HANG (TenKH, NgaySinh, SDT, GioiTinh, ThanhPho, Quan, Duong, SoNha) VALUES
(N'Nguyễn Văn An', '1985-05-15', '0901234567', N'Nam', N'Hà Nội', N'Cầu Giấy', N'Xuân Thủy', '12A'),
(N'Trần Thị Bình', '1990-08-22', '0912345678', N'Nữ', N'Hồ Chí Minh', N'Quận 1', N'Nguyễn Huệ', '34B'),
(N'Lê Quốc Cường', '1978-11-30', '0923456789', N'Nam', N'Đà Nẵng', N'Hải Châu', N'Bạch Đằng', '56C'),
(N'Phạm Thị Dung', '1995-02-18', '0934567890', N'Nữ', N'Hải Phòng', N'Lê Chân', N'Tô Hiệu', '78D'),
(N'Hoàng Văn Em', '1982-07-25', '0945678901', N'Nam', N'Cần Thơ', N'Ninh Kiều', N'30 Tháng 4', '90E');

-- Loại thẻ thành viên
INSERT INTO LOAI_THE_THANH_VIEN (Tenloaithe, Dieukien) VALUES
(N'Silver', N'Từ 100 điểm trở lên'),
(N'Gold', N'Từ 200 điểm trở lên'),
(N'Platinum', N'Từ 400 điểm trở lên');

-- Thẻ thành viên
INSERT INTO THE_THANH_VIEN (MaKH, Ngaycap, Maloaithe, DiemTichLuy) VALUES
(1, '2024-01-10', 1, 150),
(2, '2024-02-15', 2, 300),
(3, '2024-03-20', 1, 100),
(4, '2024-04-25', 3, 500),
(5, '2024-05-30', 2, 250);

-- Loại mặt hàng
INSERT INTO LOAI_MAT_HANG (TenLoai, CongDung) VALUES
(N'Áo', N'Trang phục cho phần trên của cơ thể'),
(N'Quần', N'Trang phục cho phần dưới của cơ thể'),
(N'Giày', N'Bảo vệ và trang trí cho chân'),
(N'Mũ', N'Bảo vệ và trang trí cho đầu'),
(N'Phụ kiện', N'Trang trí và hỗ trợ trang phục');

-- Mặt hàng
INSERT INTO MAT_HANG (MaLoai, TenSP, DonGia, SLTonKho, MoTaChiTiet, DonViTinh, Size) VALUES
(1, N'Áo sơ mi trắng', 250000, 100, N'Áo sơ mi trắng dài tay, chất liệu cotton', N'Cái', N'M'),
(2, N'Quần jean xanh', 350000, 150, N'Quần jean xanh đậm, form slim fit', N'Cái', N'L'),
(3, N'Giày thể thao', 500000, 80, N'Giày thể thao màu trắng, đế cao su', N'Đôi', N'42'),
(4, N'Mũ lưỡi trai', 150000, 200, N'Mũ lưỡi trai màu đen, logo thêu', N'Cái', N'Free size'),
(5, N'Khăn choàng cổ', 200000, 120, N'Khăn choàng cổ len, màu xám', N'Cái', N'Free size');

-- Nhà cung ứng
INSERT INTO NHA_CUNG_UNG (TenNCU, SDT, Email, ThanhPho, Quan, Duong, SoNha) VALUES
(N'Công ty Thời Trang Việt', '0281234567', 'contact@thoitrangviet.vn', N'Hồ Chí Minh', N'Tân Bình', N'Cộng Hòa', '123'),
(N'Công ty May Mặc ABC', '0242345678', 'info@maymacabc.com', N'Hà Nội', N'Đống Đa', N'Tây Sơn', '456'),
(N'Công ty Giày Dép XYZ', '0236356789', 'sales@giaydepxyz.vn', N'Đà Nẵng', N'Thanh Khê', N'Điện Biên Phủ', '789'),
(N'Công ty Phụ Kiện 123', '0294456789', 'support@phukien123.com', N'Cần Thơ', N'Ninh Kiều', N'3 Tháng 2', '101'),
(N'Công ty Mũ Nón MNO', '0225567890', 'contact@munonmno.vn', N'Hải Phòng', N'Lê Chân', N'Tô Hiệu', '202');
