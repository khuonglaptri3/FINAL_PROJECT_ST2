-- Create view to get all customer information along with their membership details 
CREATE VIEW v_TatCaKhachHang
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
    LTT.Tenloaithe,
    LTT.Dieukien
FROM 
    KHACH_HANG KH
LEFT JOIN 
    THE_THANH_VIEN TV ON KH.MaKH = TV.MaKH
LEFT JOIN 
    LOAI_THE_THANH_VIEN LTT ON TV.Maloaithe = LTT.Maloaithe;
GO
--view hien thi cac mat hang co trong kho 
CREATE VIEW vw_DanhSachMatHang
AS
SELECT 
    MaSP, TenSP, DonGia, SLTonKho, MoTaChiTiet, DonViTinh, Size
FROM MAT_HANG;
GO
-- view tat ca cac hoa don cua khach hang ------------
CREATE OR ALTER VIEW vw_HoaDonDaBan
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
-- view hiển thị tất cả các sản phẩm 
CREATE OR ALTER VIEW v_TatCaSanPham
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
-- view hien thi cac nha cung ung 
CREATE OR ALTER VIEW vw_TatCaNhaCungUng
AS
SELECT 
    MaNCU,
    TenNCU,
    SDT,
    Email,
    CONCAT(SoNha, ', ', Duong, ', ', Quan, ', ', ThanhPho) AS DiaChiDayDu
FROM NHA_CUNG_UNG;
-- hàm tìm kiếm nhà cung ứng theo tên và số điẹne thoại 
CREATE OR ALTER FUNCTION fn_TimNhaCungUng (@TuKhoa NVARCHAR(100))
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
-- view tat ca hoa don nhap 
CREATE OR ALTER VIEW vw_DanhSachHoaDonNhap
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
-- view top 3 san pham ban chay nhat     
CREATE OR ALTER VIEW vw_Top3SanPhamBanChay
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
-- view so luong san pham sap het hang 
CREATE OR ALTER VIEW vw_SanPhamSapHetHang
AS
SELECT TOP 100 PERCENT
    MaSP,
    TenSP,
    SLTonKho
FROM MAT_HANG
WHERE SLTonKho <= 10
ORDER BY SLTonKho ASC;
GO
-- view ti le theo loai doanh thu 
CREATE OR ALTER VIEW vw_TyLeDoanhThuTheoLoai
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
--- san pham ban cham 
CREATE OR ALTER VIEW vw_SanPhamBanCham
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
CREATE OR ALTER VIEW vw_DanhSachNhaCungUng
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



