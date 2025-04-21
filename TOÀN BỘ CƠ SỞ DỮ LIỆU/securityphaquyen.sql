    -- Tài khoản: hoasales
    CREATE LOGIN hoasales WITH PASSWORD = 'sales456';
    CREATE USER hoasales FOR LOGIN hoasales;

    -- Tài khoản: khanhchu
    CREATE LOGIN khanhchu WITH PASSWORD = 'owner789';
    CREATE USER khanhchu FOR LOGIN khanhchu;

    -- Tài khoản: tukho
    CREATE LOGIN tukho WITH PASSWORD = 'warehouse321';
    CREATE USER tukho FOR LOGIN tukho;
    -- Gán role tương ứng sau khi tạo user
ALTER ROLE nhanvien_banhang ADD MEMBER hoasales;
ALTER ROLE chu_cua_hang ADD MEMBER khanhchu;
ALTER ROLE nhanvien_nhapkho ADD MEMBER tukho;
-- flkj
SELECT dp1.name AS RoleName, dp2.name AS UserName
FROM sys.database_role_members drm
JOIN sys.database_principals dp1 ON drm.role_principal_id = dp1.principal_id
JOIN sys.database_principals dp2 ON drm.member_principal_id = dp2.principal_id
ORDER BY RoleName;

------ gán quyền 
-- Gán quyền EXECUTE cho function fn_KiemTraDangNhap
GRANT EXECUTE ON dbo.fn_KiemTraDangNhap TO nhanvien_banhang;
GRANT EXECUTE ON dbo.fn_KiemTraDangNhap TO nhanvien_nhapkho;
GRANT EXECUTE ON dbo.fn_KiemTraDangNhap TO chu_cua_hang;
-- EXECUTE quyền gọi hàm
GRANT EXECUTE ON dbo.fn_GetMaNND TO nhanvien_banhang;
GRANT EXECUTE ON dbo.fn_GetMaNND TO nhanvien_nhapkho;

-- SELECT trên các bảng được dùng trong hàm
GRANT SELECT ON dbo.DANG_NHAP TO nhanvien_banhang;
GRANT SELECT ON dbo.NHAN_VIEN TO nhanvien_banhang;

GRANT SELECT ON dbo.DANG_NHAP TO nhanvien_nhapkho;
GRANT SELECT ON dbo.NHAN_VIEN TO nhanvien_nhapkho;
GRANT SELECT ON dbo.v_TatCaKhachHang TO nhanvien_banhang;
-- Cấp SELECT trên các bảng view sử dụng
GRANT SELECT ON dbo.KHACH_HANG TO nhanvien_banhang;
GRANT SELECT ON dbo.THE_THANH_VIEN TO nhanvien_banhang;
GRANT SELECT ON dbo.LOAI_THE_THANH_VIEN TO nhanvien_banhang;

GRANT EXECUTE ON dbo.sp_CapNhatKhachHang TO nhanvien_banhang;
GRANT UPDATE ON dbo.KHACH_HANG TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_CapNhatKhachHang TO nhanvien_banhang;
GRANT UPDATE ON dbo.KHACH_HANG TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_ThemKhachHang TO nhanvien_banhang;
GRANT INSERT ON dbo.KHACH_HANG TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_ThemKhachHang TO nhanvien_banhang;
GRANT INSERT ON dbo.KHACH_HANG TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_XoaKhachHang TO nhanvien_banhang;
GRANT DELETE ON dbo.THE_THANH_VIEN TO nhanvien_banhang;
GRANT DELETE ON dbo.KHACH_HANG TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_TimKiemKhachHangNhanh TO nhanvien_banhang;
GRANT SELECT ON dbo.KHACH_HANG TO nhanvien_banhang;
GRANT SELECT ON dbo.THE_THANH_VIEN TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_TimKhachHangTheoID TO nhanvien_banhang;
GRANT SELECT ON dbo.KHACH_HANG TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_TaoHoaDon TO nhanvien_banhang;
GRANT INSERT ON dbo.MUA TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_LayChiTietHoaDon TO nhanvien_banhang;
GRANT SELECT ON dbo.CHI_TIET_MUA TO nhanvien_banhang;
GRANT SELECT ON dbo.MAT_HANG TO nhanvien_banhang;

GRANT SELECT ON dbo.vw_DanhSachMatHang TO nhanvien_banhang;
GRANT SELECT ON dbo.MAT_HANG TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_LayLoaiSanPham TO nhanvien_banhang;
GRANT SELECT ON dbo.LOAI_MAT_HANG TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_LaySanPhamTheoLoai TO nhanvien_banhang;
GRANT SELECT ON dbo.MAT_HANG TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_ThemChiTietHoaDon TO nhanvien_banhang;
GRANT SELECT, UPDATE ON dbo.MAT_HANG TO nhanvien_banhang;
GRANT INSERT ON dbo.CHI_TIET_MUA TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_XoaChiTietHoaDon TO nhanvien_banhang;
GRANT SELECT, DELETE ON dbo.CHI_TIET_MUA TO nhanvien_banhang;
GRANT UPDATE ON dbo.MAT_HANG TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_SuaChiTietHoaDon TO nhanvien_banhang;
GRANT SELECT, UPDATE ON dbo.CHI_TIET_MUA TO nhanvien_banhang;
GRANT SELECT, UPDATE ON dbo.MAT_HANG TO nhanvien_banhang;
GRANT EXECUTE ON dbo.fn_TongTienTheoKHVaHD TO nhanvien_banhang;
GRANT SELECT ON dbo.MUA TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_UpdateTongTienTheoLoaiThe TO nhanvien_banhang;
GRANT SELECT ON dbo.MUA TO nhanvien_banhang;
GRANT UPDATE ON dbo.MUA TO nhanvien_banhang;

GRANT SELECT ON dbo.THE_THANH_VIEN TO nhanvien_banhang;
GRANT SELECT ON dbo.LOAI_THE_THANH_VIEN TO nhanvien_banhang;
GRANT SELECT ON dbo.vw_HoaDonDaBan TO nhanvien_banhang;
GRANT SELECT ON dbo.vw_HoaDonDaBan TO nhanvien_nhapkho;
GRANT SELECT ON dbo.fn_TimHoaDonTheoKH TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_LayChiTietHoaDonTheoKH TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_CapNhatDiemVaLoaiThe TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_XoaHoaDon TO nhanvien_banhang;


GRANT SELECT ON dbo.v_TatCaSanPham TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_CapNhatSanPham TO nhanvien_banhang;
GRANT EXECUTE ON dbo.sp_ThemSanPham TO nhanvien_banhang;

GRANT EXECUTE ON dbo.sp_ThemSanPham TO nhanvien_banhang;
GRANT SELECT ON dbo.NHAP TO nhanvien_nhapkho;
GRANT SELECT ON dbo.NHA_CUNG_UNG TO nhanvien_nhapkho;
-- Cấp quyền SELECT trên view
GRANT SELECT ON dbo.vw_DanhSachHoaDonNhap TO nhanvien_nhapkho;

-- Cấp quyền SELECT trên các bảng mà view sử dụng
GRANT SELECT ON dbo.NHAP TO nhanvien_nhapkho;
GRANT SELECT ON dbo.NHA_CUNG_UNG TO nhanvien_nhapkho;
-- Cho phép gọi hàm (dù là TVF cũng dùng GRANT SELECT)
GRANT SELECT ON dbo.fn_TimKiemPhieuNhap TO nhanvien_nhapkho;

-- Cho phép SELECT trên các bảng mà function sử dụng
GRANT SELECT ON dbo.NHAP TO nhanvien_nhapkho;
GRANT SELECT ON dbo.NHA_CUNG_UNG TO nhanvien_nhapkho;
-- Quyền gọi hàm
GRANT SELECT ON dbo.fn_LayThongTinPhieuNhap TO nhanvien_nhapkho;

-- Quyền đọc bảng được dùng trong hàm
GRANT SELECT ON dbo.NHAP TO nhanvien_nhapkho;
GRANT SELECT ON dbo.NHA_CUNG_UNG TO nhanvien_nhapkho;
-- Cấp quyền gọi thủ tục
GRANT EXECUTE ON dbo.sp_LayLoaiSanPham TO nhanvien_nhapkho;

-- (Nếu cần) Cấp quyền đọc bảng được sử dụng trong thủ tục
GRANT SELECT ON dbo.LOAI_MAT_HANG TO nhanvien_nhapkho;
GRANT EXECUTE ON dbo.sp_LayChiTietNhapTheoHDN TO nhanvien_nhapkho;
GRANT EXECUTE ON dbo.sp_LaySanPhamTheoLoai TO nhanvien_nhapkho;
GRANT SELECT ON dbo.MAT_HANG TO nhanvien_nhapkho;
GRANT EXECUTE ON dbo.sp_ThemChiTietNhap TO nhanvien_nhapkho;
GRANT INSERT, UPDATE ON dbo.CHI_TIET_NHAP TO nhanvien_nhapkho;
GRANT SELECT, UPDATE ON dbo.MAT_HANG TO nhanvien_nhapkho;
GRANT SELECT ON dbo.NHAP TO nhanvien_nhapkho;
GRANT SELECT ON dbo.v_TatCaSanPham TO nhanvien_nhapkho;
GRANT SELECT ON dbo.MAT_HANG TO nhanvien_nhapkho;
GRANT SELECT ON dbo.LOAI_MAT_HANG TO nhanvien_nhapkho;
GRANT EXECUTE ON dbo.sp_XoaChiTietNhap TO nhanvien_nhapkho;
GRANT SELECT ON dbo.CHI_TIET_NHAP TO nhanvien_nhapkho;
GRANT DELETE ON dbo.CHI_TIET_NHAP TO nhanvien_nhapkho;
GRANT UPDATE ON dbo.MAT_HANG TO nhanvien_nhapkho;
-- Quyền thực thi thủ tục
GRANT EXECUTE ON dbo.sp_SuaChiTietNhap TO nhanvien_nhapkho;

-- Quyền thao tác trên các bảng liên quan
GRANT SELECT, UPDATE ON dbo.CHI_TIET_NHAP TO nhanvien_nhapkho;
GRANT UPDATE ON dbo.MAT_HANG TO nhanvien_nhapkho;
-- Cấp quyền SELECT trên view
GRANT SELECT ON dbo.vw_TatCaNhaCungUng TO nhanvien_nhapkho;

-- Cấp quyền SELECT trên bảng gốc nếu view truy cập trực tiếp (nếu cần)
GRANT SELECT ON dbo.NHA_CUNG_UNG TO nhanvien_nhapkho;
GRANT EXECUTE ON dbo.sp_TaoPhieuNhap TO nhanvien_nhapkho;
GRANT INSERT ON dbo.NHAP TO nhanvien_nhapkho;




-- Cấp quyền EXECUTE cho nhân viên bán hàng
GRANT EXECUTE ON dbo.fn_GetThongTinDangNhap TO nhanvien_banhang;

-- Cấp quyền EXECUTE cho nhân viên nhập kho
GRANT EXECUTE ON dbo.fn_GetThongTinDangNhap TO nhanvien_nhapkho;
