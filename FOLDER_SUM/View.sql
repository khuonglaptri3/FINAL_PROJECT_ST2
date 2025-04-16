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

