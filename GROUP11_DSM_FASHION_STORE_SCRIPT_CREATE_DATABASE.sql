-- tạo cơ sở dữ liệu mới -> new query -> paste code -> execute 
-- chủ cửa hàng có full quyền trên cơ sở dữ liệu. 

/****** Object:  User [hoasales]    Script Date: 4/21/2025 11:32:01 AM ******/
CREATE USER [hoasales] FOR LOGIN [hoasales] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [khanhchu]    Script Date: 4/21/2025 11:32:01 AM ******/
CREATE USER [khanhchu] FOR LOGIN [khanhchu] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  User [tukho]    Script Date: 4/21/2025 11:32:01 AM ******/
CREATE USER [tukho] FOR LOGIN [tukho] WITH DEFAULT_SCHEMA=[dbo]
GO
/****** Object:  DatabaseRole [chu_cua_hang]    Script Date: 4/21/2025 11:32:01 AM ******/
CREATE ROLE [chu_cua_hang]
GO
/****** Object:  DatabaseRole [nhanvien_banhang]    Script Date: 4/21/2025 11:32:01 AM ******/
CREATE ROLE [nhanvien_banhang]
GO
/****** Object:  DatabaseRole [nhanvien_nhapkho]    Script Date: 4/21/2025 11:32:01 AM ******/
CREATE ROLE [nhanvien_nhapkho]
GO
ALTER ROLE [nhanvien_banhang] ADD MEMBER [hoasales]
GO
ALTER ROLE [chu_cua_hang] ADD MEMBER [khanhchu]
GO
ALTER ROLE [nhanvien_nhapkho] ADD MEMBER [tukho]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_DoanhThuHomNay]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_DoanhThuHomNay]()
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
/****** Object:  UserDefinedFunction [dbo].[fn_GetMaNND]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetMaNND]
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
/****** Object:  UserDefinedFunction [dbo].[fn_GetThongTinDangNhap]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_GetThongTinDangNhap]
(
    @TenTaiKhoan NVARCHAR(100),
    @MatKhau NVARCHAR(100)
)
RETURNS NVARCHAR(200)
AS
BEGIN
    DECLARE @KetQua NVARCHAR(200)

    SELECT @KetQua = NV.TenNV + ' - ' + NND.TenNND
    FROM DANG_NHAP DN
    JOIN NHAN_VIEN NV ON DN.MaNV = NV.MaNV
    JOIN NHOM_NGUOI_DUNG NND ON NV.MaNND = NND.MaNND
    WHERE DN.Tentaikhoan = @TenTaiKhoan AND DN.Matkhau = @MatKhau

    RETURN ISNULL(@KetQua, N'Đăng nhập không hợp lệ')
END
GO
/****** Object:  UserDefinedFunction [dbo].[fn_KiemTraDangNhap]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[fn_KiemTraDangNhap]
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
GO
/****** Object:  UserDefinedFunction [dbo].[fn_SoHoaDonHomNay]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_SoHoaDonHomNay]()
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
/****** Object:  UserDefinedFunction [dbo].[fn_SoLuongSanPhamSapHetHang]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_SoLuongSanPhamSapHetHang]()
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
/****** Object:  UserDefinedFunction [dbo].[fn_TongSoKhachHang]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_TongSoKhachHang]()
RETURNS INT
AS
BEGIN
    RETURN (SELECT COUNT(*) FROM KHACH_HANG)
END;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TongTienTheoKHVaHD]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_TongTienTheoKHVaHD]
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
/****** Object:  Table [dbo].[NHAN_VIEN]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NHAN_VIEN](
	[MaNV] [int] IDENTITY(1,1) NOT NULL,
	[MaNND] [int] NOT NULL,
	[TenNV] [nvarchar](100) NOT NULL,
	[NgaySinh] [date] NULL,
	[SDT] [nvarchar](15) NOT NULL,
	[GioiTinh] [nvarchar](10) NULL,
	[ThanhPho] [nvarchar](50) NULL,
	[Quan] [nvarchar](50) NULL,
	[Duong] [nvarchar](50) NULL,
	[SoNha] [nvarchar](20) NULL,
 CONSTRAINT [PK_NHAN_VIEN] PRIMARY KEY CLUSTERED 
(
	[MaNV] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_NHAN_VIEN_SDT] UNIQUE NONCLUSTERED 
(
	[SDT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TimKiemNhanVien]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_TimKiemNhanVien] (@TuKhoa NVARCHAR(100))
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
GO
/****** Object:  Table [dbo].[NHOM_NGUOI_DUNG]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NHOM_NGUOI_DUNG](
	[MaNND] [int] IDENTITY(1,1) NOT NULL,
	[TenNND] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_NHOM_NGUOI_DUNG] PRIMARY KEY CLUSTERED 
(
	[MaNND] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_NhanVien]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_NhanVien]
AS
SELECT 
    NV.MaNV,
    NV.TenNV,
    NV.NgaySinh,
    NV.SDT,
    NV.GioiTinh,
    NV.ThanhPho,
    NV.Quan,
    NV.Duong,
    NV.SoNha,
    NV.MaNND,
    NND.TenNND
FROM NHAN_VIEN NV
JOIN NHOM_NGUOI_DUNG NND ON NV.MaNND = NND.MaNND;
GO
/****** Object:  Table [dbo].[MAT_HANG]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MAT_HANG](
	[MaSP] [int] IDENTITY(1,1) NOT NULL,
	[MaLoai] [int] NOT NULL,
	[TenSP] [nvarchar](100) NOT NULL,
	[DonGia] [decimal](18, 2) NULL,
	[SLTonKho] [int] NULL,
	[MoTaChiTiet] [nvarchar](max) NOT NULL,
	[DonViTinh] [nvarchar](20) NULL,
	[Size] [nvarchar](20) NULL,
 CONSTRAINT [PK_MAT_HANG] PRIMARY KEY CLUSTERED 
(
	[MaSP] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_DanhSachMatHang]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_DanhSachMatHang]
AS
SELECT 
    MaSP, TenSP, DonGia, SLTonKho, MoTaChiTiet, DonViTinh, Size
FROM MAT_HANG;
GO
/****** Object:  Table [dbo].[KHACH_HANG]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[KHACH_HANG](
	[MaKH] [int] IDENTITY(1,1) NOT NULL,
	[TenKH] [nvarchar](100) NOT NULL,
	[NgaySinh] [date] NULL,
	[SDT] [nvarchar](15) NOT NULL,
	[GioiTinh] [nvarchar](10) NULL,
	[ThanhPho] [nvarchar](50) NULL,
	[Quan] [nvarchar](50) NULL,
	[Duong] [nvarchar](50) NULL,
	[SoNha] [nvarchar](20) NULL,
 CONSTRAINT [PK_KHACH_HANG] PRIMARY KEY CLUSTERED 
(
	[MaKH] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_KHACH_HANG_SDT] UNIQUE NONCLUSTERED 
(
	[SDT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[LOAI_THE_THANH_VIEN]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LOAI_THE_THANH_VIEN](
	[Maloaithe] [int] IDENTITY(1,1) NOT NULL,
	[Tenloaithe] [nvarchar](100) NOT NULL,
	[Dieukien] [nvarchar](200) NULL,
 CONSTRAINT [PK_LOAI_THE_THANH_VIEN] PRIMARY KEY CLUSTERED 
(
	[Maloaithe] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[THE_THANH_VIEN]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[THE_THANH_VIEN](
	[Masothe] [int] IDENTITY(1,1) NOT NULL,
	[MaKH] [int] NOT NULL,
	[Ngaycap] [date] NOT NULL,
	[Maloaithe] [int] NULL,
	[DiemTichLuy] [int] NULL,
 CONSTRAINT [PK_THE_THANH_VIEN] PRIMARY KEY CLUSTERED 
(
	[Masothe] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MUA]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MUA](
	[MaHD] [int] IDENTITY(1,1) NOT NULL,
	[NgayGiaoDich] [date] NOT NULL,
	[MaKH] [int] NOT NULL,
	[TongTien] [decimal](18, 2) NULL,
 CONSTRAINT [PK_MUA] PRIMARY KEY CLUSTERED 
(
	[MaHD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_HoaDonDaBan]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_HoaDonDaBan]
AS
SELECT 
    M.MaHD,
    M.NgayGiaoDich,
    KH.MaKH,
    KH.TenKH,
    M.TongTien,
    LTV.Tenloaithe,
    TV.DiemTichLuy
FROM MUA M
JOIN KHACH_HANG KH ON M.MaKH = KH.MaKH
LEFT JOIN THE_THANH_VIEN TV ON KH.MaKH = TV.MaKH
LEFT JOIN LOAI_THE_THANH_VIEN LTV ON TV.Maloaithe = LTV.Maloaithe;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TimHoaDonTheoKH]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_TimHoaDonTheoKH] (@TuKhoa NVARCHAR(100))
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
GO
/****** Object:  Table [dbo].[LOAI_MAT_HANG]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LOAI_MAT_HANG](
	[MaLoai] [int] IDENTITY(1,1) NOT NULL,
	[TenLoai] [nvarchar](100) NOT NULL,
	[CongDung] [nvarchar](200) NULL,
 CONSTRAINT [PK_LOAI_MAT_HANG] PRIMARY KEY CLUSTERED 
(
	[MaLoai] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[v_TatCaSanPham]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[v_TatCaSanPham]
AS
SELECT 
    MH.MaSP,
    MH.TenSP,
    MH.DonGia,
    MH.SLTonKho,
    MH.DonViTinh,
    MH.Size,
    MH.MoTaChiTiet,
    MH.MaLoai,
    LMH.TenLoai AS LoaiSanPham,
    LMH.CongDung
FROM MAT_HANG MH
JOIN LOAI_MAT_HANG LMH ON MH.MaLoai = LMH.MaLoai;
GO
/****** Object:  View [dbo].[v_TatCaKhachHang]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[v_TatCaKhachHang]
AS
SELECT 
    KH.MaKH,
    KH.TenKH,
    KH.NgaySinh,
    KH.SDT,
    KH.GioiTinh,
    KH.ThanhPho,
    KH.Quan,
    KH.Duong,
    KH.SoNha,
    TV.Masothe,
    TV.Ngaycap,
    TV.DiemTichLuy,
    LTT.Tenloaithe
FROM 
    KHACH_HANG KH
LEFT JOIN 
    THE_THANH_VIEN TV ON KH.MaKH = TV.MaKH
LEFT JOIN 
    LOAI_THE_THANH_VIEN LTT ON TV.Maloaithe = LTT.Maloaithe;
GO
/****** Object:  Table [dbo].[NHA_CUNG_UNG]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NHA_CUNG_UNG](
	[MaNCU] [int] IDENTITY(1,1) NOT NULL,
	[TenNCU] [nvarchar](100) NOT NULL,
	[SDT] [nvarchar](15) NOT NULL,
	[Email] [nvarchar](100) NULL,
	[ThanhPho] [nvarchar](50) NULL,
	[Quan] [nvarchar](50) NULL,
	[Duong] [nvarchar](50) NULL,
	[SoNha] [nvarchar](20) NULL,
 CONSTRAINT [PK_NHA_CUNG_UNG] PRIMARY KEY CLUSTERED 
(
	[MaNCU] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_NHA_CUNG_UNG_EMAIL] UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
 CONSTRAINT [UQ_NHA_CUNG_UNG_SDT] UNIQUE NONCLUSTERED 
(
	[SDT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_TatCaNhaCungUng]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_TatCaNhaCungUng]
AS
SELECT 
    MaNCU,
    TenNCU,
    SDT,
    Email,
    CONCAT(SoNha, ', ', Duong, ', ', Quan, ', ', ThanhPho) AS DiaChiDayDu
FROM NHA_CUNG_UNG;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TimNhaCungUng]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_TimNhaCungUng] (@TuKhoa NVARCHAR(100))
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
/****** Object:  Table [dbo].[NHAP]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[NHAP](
	[MaHDN] [int] IDENTITY(1,1) NOT NULL,
	[NgayDat] [date] NOT NULL,
	[TongTien] [decimal](18, 2) NULL,
	[MaNCU] [int] NOT NULL,
 CONSTRAINT [PK_NHAP] PRIMARY KEY CLUSTERED 
(
	[MaHDN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_LayThongTinPhieuNhap]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_LayThongTinPhieuNhap](@MaHDN INT)
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
GO
/****** Object:  View [dbo].[vw_DanhSachHoaDonNhap]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_DanhSachHoaDonNhap]
AS
SELECT 
    N.MaHDN,
    N.NgayDat,
    N.TongTien,
    NCU.MaNCU,
    NCU.TenNCU,
    NCU.SDT
FROM NHAP N
JOIN NHA_CUNG_UNG NCU ON N.MaNCU = NCU.MaNCU;
GO
/****** Object:  UserDefinedFunction [dbo].[fn_TimKiemPhieuNhap]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   FUNCTION [dbo].[fn_TimKiemPhieuNhap]
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
/****** Object:  Table [dbo].[CHI_TIET_MUA]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CHI_TIET_MUA](
	[MaSP] [int] NOT NULL,
	[MaHD] [int] NOT NULL,
	[SoLuong] [int] NOT NULL,
	[ChietKhau] [decimal](18, 2) NULL,
	[VAT] [decimal](18, 2) NULL,
 CONSTRAINT [PK_CHI_TIET_MUA] PRIMARY KEY CLUSTERED 
(
	[MaSP] ASC,
	[MaHD] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_Top3SanPhamBanChay]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_Top3SanPhamBanChay]
AS
SELECT TOP 3 
    MH.TenSP,
    SUM(CTM.SoLuong) AS SoLuongBan
FROM CHI_TIET_MUA CTM
JOIN MUA M ON CTM.MaHD = M.MaHD
JOIN MAT_HANG MH ON CTM.MaSP = MH.MaSP
WHERE M.NgayGiaoDich >= DATEADD(DAY, -7, GETDATE())
GROUP BY MH.TenSP
ORDER BY SoLuongBan DESC;
GO
/****** Object:  View [dbo].[vw_SanPhamSapHetHang]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_SanPhamSapHetHang]
AS
SELECT TOP 100 PERCENT
    MaSP,
    TenSP,
    SLTonKho
FROM MAT_HANG
WHERE SLTonKho <= 10
ORDER BY SLTonKho ASC;
GO
/****** Object:  View [dbo].[vw_TyLeDoanhThuTheoLoai]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_TyLeDoanhThuTheoLoai]
AS
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
/****** Object:  View [dbo].[vw_SanPhamBanCham]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_SanPhamBanCham]
AS
SELECT MH.MaSP, MH.TenSP, MH.SLTonKho
FROM MAT_HANG MH
WHERE NOT EXISTS (
    SELECT 1
    FROM CHI_TIET_MUA CTM
    JOIN MUA M ON CTM.MaHD = M.MaHD
    WHERE CTM.MaSP = MH.MaSP 
      AND M.NgayGiaoDich >= DATEADD(DAY, -7, GETDATE())
);
GO
/****** Object:  View [dbo].[vw_DanhSachNhaCungUng]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   VIEW [dbo].[vw_DanhSachNhaCungUng]
AS
SELECT 
    MaNCU,
    TenNCU,
    SDT,
    Email,
    ThanhPho,
    Quan,
    Duong,
    SoNha
FROM NHA_CUNG_UNG;
GO
/****** Object:  Table [dbo].[CHI_TIET_NHAP]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[CHI_TIET_NHAP](
	[MaSP] [int] NOT NULL,
	[MaHDN] [int] NOT NULL,
	[SoLuong] [int] NOT NULL,
	[ChietKhau] [decimal](18, 2) NULL,
	[VAT] [decimal](18, 2) NULL,
 CONSTRAINT [PK_CHI_TIET_NHAP] PRIMARY KEY CLUSTERED 
(
	[MaSP] ASC,
	[MaHDN] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[DANG_NHAP]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DANG_NHAP](
	[MaNV] [int] NOT NULL,
	[Tentaikhoan] [nvarchar](100) NOT NULL,
	[Matkhau] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_DANG_NHAP] PRIMARY KEY CLUSTERED 
(
	[Tentaikhoan] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[PHANQUYEN]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[PHANQUYEN](
	[MaNND] [int] NOT NULL,
	[MaQuyen] [int] NOT NULL,
	[Mota] [nvarchar](200) NULL,
 CONSTRAINT [PK_PHANQUYEN] PRIMARY KEY CLUSTERED 
(
	[MaNND] ASC,
	[MaQuyen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[QUYEN]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[QUYEN](
	[MaQuyen] [int] IDENTITY(1,1) NOT NULL,
	[TenQuyen] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_QUYEN] PRIMARY KEY CLUSTERED 
(
	[MaQuyen] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CHI_TIET_MUA]  WITH CHECK ADD  CONSTRAINT [FK_CHI_TIET_MUA_MAT_HANG] FOREIGN KEY([MaSP])
REFERENCES [dbo].[MAT_HANG] ([MaSP])
GO
ALTER TABLE [dbo].[CHI_TIET_MUA] CHECK CONSTRAINT [FK_CHI_TIET_MUA_MAT_HANG]
GO
ALTER TABLE [dbo].[CHI_TIET_MUA]  WITH CHECK ADD  CONSTRAINT [FK_CHI_TIET_MUA_MUA] FOREIGN KEY([MaHD])
REFERENCES [dbo].[MUA] ([MaHD])
GO
ALTER TABLE [dbo].[CHI_TIET_MUA] CHECK CONSTRAINT [FK_CHI_TIET_MUA_MUA]
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP]  WITH CHECK ADD  CONSTRAINT [FK_CHI_TIET_NHAP_MAT_HANG] FOREIGN KEY([MaSP])
REFERENCES [dbo].[MAT_HANG] ([MaSP])
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP] CHECK CONSTRAINT [FK_CHI_TIET_NHAP_MAT_HANG]
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP]  WITH CHECK ADD  CONSTRAINT [FK_CHI_TIET_NHAP_NHAP] FOREIGN KEY([MaHDN])
REFERENCES [dbo].[NHAP] ([MaHDN])
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP] CHECK CONSTRAINT [FK_CHI_TIET_NHAP_NHAP]
GO
ALTER TABLE [dbo].[DANG_NHAP]  WITH CHECK ADD  CONSTRAINT [FK_DANG_NHAP_NHAN_VIEN] FOREIGN KEY([MaNV])
REFERENCES [dbo].[NHAN_VIEN] ([MaNV])
GO
ALTER TABLE [dbo].[DANG_NHAP] CHECK CONSTRAINT [FK_DANG_NHAP_NHAN_VIEN]
GO
ALTER TABLE [dbo].[MAT_HANG]  WITH CHECK ADD  CONSTRAINT [FK_MAT_HANG_LOAI_MAT_HANG] FOREIGN KEY([MaLoai])
REFERENCES [dbo].[LOAI_MAT_HANG] ([MaLoai])
GO
ALTER TABLE [dbo].[MAT_HANG] CHECK CONSTRAINT [FK_MAT_HANG_LOAI_MAT_HANG]
GO
ALTER TABLE [dbo].[MUA]  WITH CHECK ADD  CONSTRAINT [FK_MUA_KHACH_HANG] FOREIGN KEY([MaKH])
REFERENCES [dbo].[KHACH_HANG] ([MaKH])
GO
ALTER TABLE [dbo].[MUA] CHECK CONSTRAINT [FK_MUA_KHACH_HANG]
GO
ALTER TABLE [dbo].[NHAN_VIEN]  WITH CHECK ADD  CONSTRAINT [FK_NHAN_VIEN_NHOM_NGUOI_DUNG] FOREIGN KEY([MaNND])
REFERENCES [dbo].[NHOM_NGUOI_DUNG] ([MaNND])
GO
ALTER TABLE [dbo].[NHAN_VIEN] CHECK CONSTRAINT [FK_NHAN_VIEN_NHOM_NGUOI_DUNG]
GO
ALTER TABLE [dbo].[NHAP]  WITH CHECK ADD  CONSTRAINT [FK_NHAP_NHA_CUNG_UNG] FOREIGN KEY([MaNCU])
REFERENCES [dbo].[NHA_CUNG_UNG] ([MaNCU])
GO
ALTER TABLE [dbo].[NHAP] CHECK CONSTRAINT [FK_NHAP_NHA_CUNG_UNG]
GO
ALTER TABLE [dbo].[PHANQUYEN]  WITH CHECK ADD  CONSTRAINT [FK_PHANQUYEN_NHOM_NGUOI_DUNG] FOREIGN KEY([MaNND])
REFERENCES [dbo].[NHOM_NGUOI_DUNG] ([MaNND])
GO
ALTER TABLE [dbo].[PHANQUYEN] CHECK CONSTRAINT [FK_PHANQUYEN_NHOM_NGUOI_DUNG]
GO
ALTER TABLE [dbo].[PHANQUYEN]  WITH CHECK ADD  CONSTRAINT [FK_PHANQUYEN_QUYEN] FOREIGN KEY([MaQuyen])
REFERENCES [dbo].[QUYEN] ([MaQuyen])
GO
ALTER TABLE [dbo].[PHANQUYEN] CHECK CONSTRAINT [FK_PHANQUYEN_QUYEN]
GO
ALTER TABLE [dbo].[THE_THANH_VIEN]  WITH CHECK ADD  CONSTRAINT [FK_THE_THANH_VIEN_KHACH_HANG] FOREIGN KEY([MaKH])
REFERENCES [dbo].[KHACH_HANG] ([MaKH])
GO
ALTER TABLE [dbo].[THE_THANH_VIEN] CHECK CONSTRAINT [FK_THE_THANH_VIEN_KHACH_HANG]
GO
ALTER TABLE [dbo].[THE_THANH_VIEN]  WITH CHECK ADD  CONSTRAINT [FK_THE_THANH_VIEN_LOAI_THE_THANH_VIEN] FOREIGN KEY([Maloaithe])
REFERENCES [dbo].[LOAI_THE_THANH_VIEN] ([Maloaithe])
GO
ALTER TABLE [dbo].[THE_THANH_VIEN] CHECK CONSTRAINT [FK_THE_THANH_VIEN_LOAI_THE_THANH_VIEN]
GO
ALTER TABLE [dbo].[CHI_TIET_MUA]  WITH CHECK ADD CHECK  (([ChietKhau]>=(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_MUA]  WITH CHECK ADD CHECK  (([ChietKhau]>=(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_MUA]  WITH CHECK ADD CHECK  (([ChietKhau]>=(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_MUA]  WITH CHECK ADD CHECK  (([SoLuong]>(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_MUA]  WITH CHECK ADD CHECK  (([SoLuong]>(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_MUA]  WITH CHECK ADD CHECK  (([SoLuong]>(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_MUA]  WITH CHECK ADD CHECK  (([VAT]>=(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_MUA]  WITH CHECK ADD CHECK  (([VAT]>=(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_MUA]  WITH CHECK ADD CHECK  (([VAT]>=(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP]  WITH CHECK ADD CHECK  (([ChietKhau]>=(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP]  WITH CHECK ADD CHECK  (([ChietKhau]>=(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP]  WITH CHECK ADD CHECK  (([ChietKhau]>=(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP]  WITH CHECK ADD CHECK  (([SoLuong]>(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP]  WITH CHECK ADD CHECK  (([SoLuong]>(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP]  WITH CHECK ADD CHECK  (([SoLuong]>(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP]  WITH CHECK ADD CHECK  (([VAT]>=(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP]  WITH CHECK ADD CHECK  (([VAT]>=(0)))
GO
ALTER TABLE [dbo].[CHI_TIET_NHAP]  WITH CHECK ADD CHECK  (([VAT]>=(0)))
GO
ALTER TABLE [dbo].[KHACH_HANG]  WITH CHECK ADD CHECK  (([GioiTinh]=N'Nữ' OR [GioiTinh]=N'Nam'))
GO
ALTER TABLE [dbo].[KHACH_HANG]  WITH CHECK ADD CHECK  (([GioiTinh]=N'Nữ' OR [GioiTinh]=N'Nam'))
GO
ALTER TABLE [dbo].[KHACH_HANG]  WITH CHECK ADD CHECK  (([GioiTinh]=N'Nữ' OR [GioiTinh]=N'Nam'))
GO
ALTER TABLE [dbo].[MAT_HANG]  WITH CHECK ADD CHECK  (([DonGia]>=(0)))
GO
ALTER TABLE [dbo].[MAT_HANG]  WITH CHECK ADD CHECK  (([DonGia]>=(0)))
GO
ALTER TABLE [dbo].[MAT_HANG]  WITH CHECK ADD CHECK  (([DonGia]>=(0)))
GO
ALTER TABLE [dbo].[MAT_HANG]  WITH CHECK ADD CHECK  (([SLTonKho]>=(0)))
GO
ALTER TABLE [dbo].[MAT_HANG]  WITH CHECK ADD CHECK  (([SLTonKho]>=(0)))
GO
ALTER TABLE [dbo].[MAT_HANG]  WITH CHECK ADD CHECK  (([SLTonKho]>=(0)))
GO
ALTER TABLE [dbo].[MUA]  WITH CHECK ADD CHECK  (([TongTien]>=(0)))
GO
ALTER TABLE [dbo].[MUA]  WITH CHECK ADD CHECK  (([TongTien]>=(0)))
GO
ALTER TABLE [dbo].[MUA]  WITH CHECK ADD CHECK  (([TongTien]>=(0)))
GO
ALTER TABLE [dbo].[NHAN_VIEN]  WITH CHECK ADD CHECK  (([GioiTinh]=N'Nữ' OR [GioiTinh]=N'Nam'))
GO
ALTER TABLE [dbo].[NHAN_VIEN]  WITH CHECK ADD CHECK  (([GioiTinh]=N'Nữ' OR [GioiTinh]=N'Nam'))
GO
ALTER TABLE [dbo].[NHAN_VIEN]  WITH CHECK ADD CHECK  (([GioiTinh]=N'Nữ' OR [GioiTinh]=N'Nam'))
GO
ALTER TABLE [dbo].[NHAP]  WITH CHECK ADD CHECK  (([TongTien]>=(0)))
GO
ALTER TABLE [dbo].[NHAP]  WITH CHECK ADD CHECK  (([TongTien]>=(0)))
GO
ALTER TABLE [dbo].[NHAP]  WITH CHECK ADD CHECK  (([TongTien]>=(0)))
GO
ALTER TABLE [dbo].[THE_THANH_VIEN]  WITH CHECK ADD CHECK  (([DiemTichLuy]>=(0)))
GO
ALTER TABLE [dbo].[THE_THANH_VIEN]  WITH CHECK ADD CHECK  (([DiemTichLuy]>=(0)))
GO
ALTER TABLE [dbo].[THE_THANH_VIEN]  WITH CHECK ADD CHECK  (([DiemTichLuy]>=(0)))
GO
/****** Object:  StoredProcedure [dbo].[sp_CapNhatDiemVaLoaiThe]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_CapNhatDiemVaLoaiThe]
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
/****** Object:  StoredProcedure [dbo].[sp_CapNhatKhachHang]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_CapNhatKhachHang]
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
/****** Object:  StoredProcedure [dbo].[sp_CapNhatNhaCungUng]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Thu tuc cap nhat nha cung ung 
CREATE   PROCEDURE [dbo].[sp_CapNhatNhaCungUng]
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
/****** Object:  StoredProcedure [dbo].[sp_CapNhatNhanVien]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- thu tuc cap nhat  nhan vien 
CREATE   PROCEDURE [dbo].[sp_CapNhatNhanVien]
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
/****** Object:  StoredProcedure [dbo].[sp_CapNhatSanPham]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_CapNhatSanPham]
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
/****** Object:  StoredProcedure [dbo].[sp_LayChiTietHoaDon]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- thu tuc hien thi chi tiet mot hoa don tra ve 1 bang voi tham so la mahd 
CREATE   PROCEDURE [dbo].[sp_LayChiTietHoaDon]
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
/****** Object:  StoredProcedure [dbo].[sp_LayChiTietHoaDonTheoKH]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- thu tuc lay chi tiet hoa don tu mahd va makh 
CREATE   PROCEDURE [dbo].[sp_LayChiTietHoaDonTheoKH]
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
/****** Object:  StoredProcedure [dbo].[sp_LayChiTietNhapTheoHDN]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_LayChiTietNhapTheoHDN]
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
/****** Object:  StoredProcedure [dbo].[sp_LayLoaiSanPham]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- thủ tục lấy mã loại sản phẩm và tên sản phẩm 
CREATE   PROCEDURE [dbo].[sp_LayLoaiSanPham]
AS
BEGIN
    SELECT MaLoai, TenLoai FROM LOAI_MAT_HANG;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_LaySanPhamTheoLoai]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- thủ tục lọc sản phẩm theo loại sản phẩm 
CREATE   PROCEDURE [dbo].[sp_LaySanPhamTheoLoai]
    @MaLoai INT
AS
BEGIN
    SELECT 
        MaSP, TenSP, DonGia, SLTonKho, MoTaChiTiet, DonViTinh, Size
    FROM MAT_HANG
    WHERE MaLoai = @MaLoai;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_SuaChiTietHoaDon]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- thu tuc co tham so cap nhat chi tiet hoa don 
CREATE   PROCEDURE [dbo].[sp_SuaChiTietHoaDon]
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
/****** Object:  StoredProcedure [dbo].[sp_SuaChiTietNhap]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_SuaChiTietNhap]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_TaoHoaDon]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- thu tuc them 1 hoa don moi 
CREATE   PROCEDURE [dbo].[sp_TaoHoaDon]
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
/****** Object:  StoredProcedure [dbo].[sp_TaoLoginChoNhanVien]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_TaoLoginChoNhanVien]
    @TenDangNhap NVARCHAR(100),
    @MatKhau NVARCHAR(100)
AS
BEGIN
    DECLARE @SQL NVARCHAR(MAX);

    -- Tạo LOGIN
    SET @SQL = '
    IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = ''' + @TenDangNhap + ''')
        CREATE LOGIN [' + @TenDangNhap + '] WITH PASSWORD = ''' + @MatKhau + ''';';
    EXEC (@SQL);

    -- Tạo USER trong database
    SET @SQL = '
    IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = ''' + @TenDangNhap + ''')
    BEGIN
        CREATE USER [' + @TenDangNhap + '] FOR LOGIN [' + @TenDangNhap + '];
        GRANT SELECT, INSERT, UPDATE, DELETE TO [' + @TenDangNhap + '];
    END';
    EXEC (@SQL);
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_TaoPhieuNhap]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_TaoPhieuNhap]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemChiTietHoaDon]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- thủ tục them chi tiết hóa đơn 
CREATE   PROCEDURE [dbo].[sp_ThemChiTietHoaDon]
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
/****** Object:  StoredProcedure [dbo].[sp_ThemChiTietNhap]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_ThemChiTietNhap]
    @MaHDN INT,
    @MaSP INT,
    @SoLuong INT,
    @ChietKhau FLOAT = 0,
    @VAT FLOAT = 0
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Kiểm tra dữ liệu đầu vào
    IF @SoLuong <= 0 OR @ChietKhau > 100 OR @VAT > 100
    BEGIN
        RAISERROR(N'Dữ liệu không hợp lệ.', 16, 1);
        RETURN;
    END

    -- 2. Kiểm tra MaHDN và MaSP có tồn tại không
    IF NOT EXISTS (SELECT 1 FROM NHAP WHERE MaHDN = @MaHDN)
    BEGIN
        RAISERROR(N'Mã phiếu nhập không tồn tại.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM MAT_HANG WHERE MaSP = @MaSP)
    BEGIN
        RAISERROR(N'Mã sản phẩm không tồn tại.', 16, 1);
        RETURN;
    END

    -- 3. Kiểm tra nếu đã tồn tại chi tiết thì cập nhật số lượng
    IF EXISTS (SELECT 1 FROM CHI_TIET_NHAP WHERE MaHDN = @MaHDN AND MaSP = @MaSP)
    BEGIN
        -- Cộng thêm số lượng
        UPDATE CHI_TIET_NHAP
        SET 
            SoLuong = SoLuong + @SoLuong,
            ChietKhau = @ChietKhau,
            VAT = @VAT
        WHERE MaHDN = @MaHDN AND MaSP = @MaSP;
    END
    ELSE
    BEGIN
        -- Thêm mới
        INSERT INTO CHI_TIET_NHAP (MaHDN, MaSP, SoLuong, ChietKhau, VAT)
        VALUES (@MaHDN, @MaSP, @SoLuong, @ChietKhau, @VAT);
    END

    -- 4. Cập nhật tồn kho
    UPDATE MAT_HANG
    SET SLTonKho = SLTonKho + @SoLuong
    WHERE MaSP = @MaSP;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_ThemKhachHang]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_ThemKhachHang]
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
/****** Object:  StoredProcedure [dbo].[sp_ThemNhaCungUng]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_ThemNhaCungUng]
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
/****** Object:  StoredProcedure [dbo].[sp_ThemNhanVien]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_ThemNhanVien]
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
/****** Object:  StoredProcedure [dbo].[sp_ThemSanPham]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_ThemSanPham]
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
/****** Object:  StoredProcedure [dbo].[sp_TimKhachHangTheoID]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_TimKhachHangTheoID]
    @MaKH INT
AS
BEGIN
    SELECT TenKH, SDT FROM KHACH_HANG WHERE MaKH = @MaKH;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_TimKiemKhachHangNhanh]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


    -- ===============================================
    -- THỦ TỤC: sp_TimKiemKhachHangNhanh
    -- Loại: Stored Procedure
    -- Tham số: Có (@TuKhoa NVARCHAR)
    -- Trả về: Bảng (SELECT)
    -- Mục đích: Tìm kiếm khách hàng theo tên, SDT hoặc mã
    -- ===============================================
CREATE PROCEDURE [dbo].[sp_TimKiemKhachHangNhanh]
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
/****** Object:  StoredProcedure [dbo].[sp_TimNhaCungUngTheoTuKhoa]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_TimNhaCungUngTheoTuKhoa]
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
/****** Object:  StoredProcedure [dbo].[sp_UpdateTongTienTheoLoaiThe]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_UpdateTongTienTheoLoaiThe]
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
/****** Object:  StoredProcedure [dbo].[sp_XoaChiTietHoaDon]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_XoaChiTietHoaDon]
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
/****** Object:  StoredProcedure [dbo].[sp_XoaChiTietNhap]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_XoaChiTietNhap]
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
GO
/****** Object:  StoredProcedure [dbo].[sp_XoaHoaDon]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- thu tuc xoa hoa don dua tren MaHD 
CREATE   PROCEDURE [dbo].[sp_XoaHoaDon]
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
/****** Object:  StoredProcedure [dbo].[sp_XoaKhachHang]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_XoaKhachHang]
    @MaKH INT
AS
BEGIN
    -- Xóa thẻ thành viên nếu có
    DELETE FROM THE_THANH_VIEN WHERE MaKH = @MaKH;

    -- Xóa khách hàng (nếu trigger cho phép)
    DELETE FROM KHACH_HANG WHERE MaKH = @MaKH;
END;
GO
/****** Object:  StoredProcedure [dbo].[sp_XoaLoginNhanVien]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_XoaLoginNhanVien]
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
/****** Object:  StoredProcedure [dbo].[sp_XoaNhaCungUng]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ❌ 3. Xóa nhà cung ứng (kiểm tra nếu đã có phiếu nhập)
CREATE   PROCEDURE [dbo].[sp_XoaNhaCungUng]
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
/****** Object:  StoredProcedure [dbo].[sp_XoaNhanVien]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_XoaNhanVien]
    @MaNV INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Xoá tài khoản ứng dụng trước (nếu có)
    DELETE FROM DANG_NHAP WHERE MaNV = @MaNV;

    -- Xoá nhân viên
    DELETE FROM NHAN_VIEN WHERE MaNV = @MaNV;
END
GO
/****** Object:  StoredProcedure [dbo].[sp_XoaSanPham]    Script Date: 4/21/2025 11:32:01 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE   PROCEDURE [dbo].[sp_XoaSanPham]
    @MaSP INT
AS
BEGIN
    SET NOCOUNT ON;

    -- Xóa sản phẩm (Trigger sẽ tự kiểm tra nếu sản phẩm liên kết với bảng khác)
    DELETE FROM MAT_HANG WHERE MaSP = @MaSP;
END;
GO
