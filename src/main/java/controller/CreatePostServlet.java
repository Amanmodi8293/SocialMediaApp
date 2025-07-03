package controller;

import java.io.*;
import java.nio.file.Paths;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;
import org.apache.commons.io.FilenameUtils;

@WebServlet("/CreatePostServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2, // 2MB
                 maxFileSize = 1024 * 1024 * 10,      // 10MB
                 maxRequestSize = 1024 * 1024 * 50)   // 50MB
public class CreatePostServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        HttpSession session = req.getSession();
        Integer userId = (Integer) session.getAttribute("user_id");
        if (userId == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        String content = req.getParameter("content");
        Part filePart = req.getPart("image");
        String imagePath = null;

        if (filePart != null && filePart.getSize() > 0) {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String extension = FilenameUtils.getExtension(fileName);
            String newFileName = "post_" + System.currentTimeMillis() + "." + extension;

            String uploadDir = getServletContext().getRealPath("/") + "uploads";
            File uploadFolder = new File(uploadDir);
            if (!uploadFolder.exists()) uploadFolder.mkdir();

            File file = new File(uploadFolder, newFileName);
            try (InputStream input = filePart.getInputStream();
                 FileOutputStream fos = new FileOutputStream(file)) {
                byte[] buffer = new byte[1024];
                int bytesRead;
                while ((bytesRead = input.read(buffer)) != -1) {
                    fos.write(buffer, 0, bytesRead);
                }
            }
            imagePath = "uploads/" + newFileName;
        }

        try {
        	Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement("INSERT INTO posts (user_id, content, image_path) VALUES (?, ?, ?)");
            ps.setInt(1, userId);
            ps.setString(2, content);
            ps.setString(3, imagePath);
            ps.executeUpdate();

            res.sendRedirect("profile.jsp"); // or post_feed.jsp
        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().println("Post failed: " + e.getMessage());
        }
    }
}
