
-- trả về 1 nếu tài khoản và mật khẩu hợp lệ, 0 nếu không hợp lệ 
-- Tạo hàm kiểm tra tài khoản và mật khẩu   tham số đầu vào là Tentaikhoan, Matkhau
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

