-- VIẾT STORE PROCEDURE TÊN  LÀ SP_XEPLOAISINHVIENTHEODIEMTB NHẬN VÀO MÃ SINH VIÊN VÀ TẺ VỀ THÔNG XẾP LẠI

USE `qlsinhvien`;


DELIMITER // 

CREATE PROCEDURE Sp_XepLoaiSinhVienTheoDiemTB(IN `p_Student_id` VARCHAR(5),
											  OUT `p_Student_Rank` VARCHAR(100))
BEGIN
	DECLARE `p_Student_Score_Tb` FLOAT;
	SELECT ROUND(AVG(`Diem`), 2) INTO `p_Student_Score_Tb`
    FROM `diem`
    WHERE `MaSV` = `p_Student_id`;
    
    IF `p_Student_Score_Tb` IS NULL THEN
		SET `p_Student_Rank` = 'chưa có điểm của sinh viên';
    ELSEIF `p_Student_Score_Tb` >= 8.5 THEN
		SET `p_Student_Rank` = 'Xuất sắc';
	ELSEIF `p_Student_Score_Tb` >= 8.0 THEN
		SET `p_Student_Rank` = 'Giỏi';
	ELSE
		SET `p_Student_Rank` = 'Cần nỗ lực thêm';
	END IF;
    
    SELECT `p_Student_id` AS `Mã sinh viên`, `p_Student_Rank` AS `Rank`, `p_Student_Score_Tb` AS `Điểm`;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS `Sp_XepLoaiSinhVienTheoDiemTB`;


-- CÓ ĐIỂM
CALL Sp_XepLoaiSinhVienTheoDiemTB('SV001', @R_ANK);

-- CHƯA CÓ ĐIỂM NÀO
CALL Sp_XepLoaiSinhVienTheoDiemTB('SV020', @R_ANK);


-- Viết Stored Procedure tên là sp_DangKyMonHoc thực hiện chức năng đăng ký môn học cho sinh viên.

DELIMITER //
CREATE PROCEDURE sp_DangKyMonHoc (IN `p_MaSV` VARCHAR(10),
								  IN `p_MaMH` VARCHAR(10),
                                  OUT `p_ThongBao` VARCHAR(100))
BEGIN 
	DECLARE `p_Count_Enrollment` INT;
    
	SELECT COUNT(*) INTO `p_Count_Enrollment`
    FROM `diem`
    WHERE `MaSV` = `p_MaSV` AND `MaMH` = `p_MaMH`;
    
    
    IF `p_Count_Enrollment` = 0 THEN
		INSERT INTO `diem`
        VALUES 
			(`p_MaSV`, `p_MaMH`, 0, 1, CURRENT_DATE());
		SET `p_ThongBao` = 'Đăng ký môn học thành công!';
	ELSE
		SET `p_ThongBao` = 'Sinh viên đã đăng ký môn này!';
	END IF; 
    SELECT `p_MaSV` AS `Mã sinh viên`, `p_MaMH` AS `Mã Môn học`, `p_ThongBao` AS `Thông báo`;
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_DangKyMonHoc;

-- CÓ NGƯỜI ĐĂNG KÝ KHÓA HỌC
CALL sp_DangKyMonHoc('SV001', 'MH001', @thongbao);
		
-- SINH VIÊN CHƯA ĐĂNG KÝ MÔN NÀY
CALL sp_DangKyMonHoc('SV020', 'MH001', @thongbao);


-- CÂU 3: 
DELIMITER //
CREATE PROCEDURE sp_CapNhatDiem(IN `p_MaSV` VARCHAR(10),
								IN `p_MaMH` VARCHAR(10),
                                IN `p_DiemMoi` FLOAT,
                                OUT `p_ThongBao` VARCHAR(100))
                                
BEGIN
	DECLARE `p_Old_Student_Point` FLOAT;
    SELECT `Diem`  INTO `p_Old_Student_Point`
    FROM `diem`
    WHERE `MaSV` = `p_MaSV` AND `MaMH` = `p_MaMH`;
    
	IF (`p_MaSV` IS NULL OR `p_MaMH` IS NULL) THEN
		SET `p_ThongBao` = 'Sinh viên chưa đăng ký môn học này !';
	ELSEIF `p_DiemMoi` < 0 OR `p_DiemMoi` > 10 THEN
		SET `p_ThongBao` = 'Điểm không hợp lệ';
	ELSE
		UPDATE `diem`
        SET `Diem` = `p_DiemMoi`
        WHERE `MaSV` = `p_MaSV` AND `MaMH` = `p_MaMH`;
		SET `p_ThongBao` = 'Cập nhật điểm thành công!';
	END IF; 
    
    SELECT `p_MaSV` AS `Mã Sinh Viên`,
    `p_MaMH` AS `Mã môn học`,
    `p_Old_Student_Point` AS `Điểm môn học cũ`,
    `p_DiemMoi`AS `Điểm môn học mới`,
    `p_ThongBao` AS `Thông báo`;
END //
DELIMITER ;
	
DROP PROCEDURE IF EXISTS sp_CapNhatDiem;

-- Test Câu 3
CALL sp_CapNhatDiem('SV001', 'MH001', 8.0, @msg);
SELECT @msg;


-- CÂU 4: Viết Stored Procedure tên là sp_ThongKeSinhVienKhoa thống kê nhanh một khoa
DELIMITER //
CREATE PROCEDURE sp_ThongKeSinhVienKhoa(IN `p_MaKhoa` VARCHAR(10),
										OUT `p_SoSinhVien` INT,
                                        OUT `p_DiemTB` FLOAT,
                                        OUT `p_ThongBao` VARCHAR(100))
BEGIN
	SELECT
		COUNT(DISTINCT S.`MaSV`), ROUND(AVG(D. `Diem`),2) INTO 
        `p_SoSinhVien`,`p_DiemTB`
        FROM `sinhvien` S
        LEFT JOIN `diem` D ON D.`MaSV` = S.`MaSV`
        LEFT JOIN `monhoc` M ON M.`MaMH` = D.`MaMH`
        LEFT JOIN `khoa` K ON K.`MaKhoa` = M.`MaKhoa`
        WHERE S.`MaKhoa` = `p_MaKhoa`;
        
    SELECT CONCAT('Khoa ', p_MaKhoa, ' Có ', p_SoSinhVien, ' Sinh viên, Điểm TB: ', p_DiemTB) AS `Thông báo`;
	
END //
DELIMITER ;

DROP PROCEDURE IF EXISTS sp_ThongKeSinhVienKhoa;

-- Test Câu 4
CALL sp_ThongKeSinhVienKhoa('CNTT', @sosv, @dtb, @msg);
SELECT @sosv, @dtb, @msg;