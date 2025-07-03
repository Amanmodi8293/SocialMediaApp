package controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.sql.Connection;
import java.sql.PreparedStatement;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;
import util.DBConnection;

@WebServlet("/UploadReelServlet")
@MultipartConfig
public class UploadReelServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");

        if (userId == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        String caption = req.getParameter("caption");
        Part videoPart = req.getPart("video");

        if (videoPart == null || videoPart.getSize() == 0) {
            System.out.println("No video file uploaded!");
            res.sendRedirect("upload_reel.jsp");
            return;
        }

        String fileName = System.currentTimeMillis() + "_" + videoPart.getSubmittedFileName();
        String uploadPath = getServletContext().getRealPath("/") + "uploads/reels/";
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        File videoFile = new File(uploadPath + fileName);
        System.out.println("Uploading to: " + videoFile.getAbsolutePath());

        Files.copy(videoPart.getInputStream(), videoFile.toPath(), StandardCopyOption.REPLACE_EXISTING);

        if (!videoFile.exists()) {
            System.out.println("❌ File not saved.");
        } else {
            System.out.println("✅ File uploaded successfully.");
        }

        // Save path in DB
        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "INSERT INTO reels (user_id, caption, video_path) VALUES (?, ?, ?)");
            ps.setInt(1, userId);
            ps.setString(2, caption);
            ps.setString(3, "uploads/reels/" + fileName);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }

        res.sendRedirect("reels.jsp");
    }
}
