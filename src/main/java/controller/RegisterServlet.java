package controller;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/RegisterServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024,    // 1MB
                 maxFileSize = 1024 * 1024 * 5,      // 5MB
                 maxRequestSize = 1024 * 1024 * 10)  // 10MB
public class RegisterServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        req.setCharacterEncoding("UTF-8");
        res.setContentType("text/html;charset=UTF-8");

        String name = req.getParameter("name");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String bio = req.getParameter("bio");
        Part profilePart = null;
        String profilePic = "default.png"; // fallback image

        try {
            profilePart = req.getPart("profile_pic");

            // Save profile picture to /uploads folder
            if (profilePart != null && profilePart.getSize() > 0) {
                String fileName = System.currentTimeMillis() + "_" + profilePart.getSubmittedFileName();
                String uploadPath = getServletContext().getRealPath("/") + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();

                profilePart.write(uploadPath + File.separator + fileName);
                profilePic = "uploads/" + fileName; // store path in DB
            }

            try (Connection conn = DBConnection.getConnection()) {
                // Check if email already exists
                PreparedStatement check = conn.prepareStatement("SELECT id FROM users WHERE email = ?");
                check.setString(1, email);
                ResultSet rs = check.executeQuery();
                if (rs.next()) {
                    res.sendRedirect("register.jsp?error=true");
                    return;
                }

                // Insert user data into database
                PreparedStatement insert = conn.prepareStatement(
                    "INSERT INTO users (name, email, password, bio, profile_pic) VALUES (?, ?, ?, ?, ?)");
                insert.setString(1, name);
                insert.setString(2, email);
                insert.setString(3, password); // optional: hash in production
                insert.setString(4, bio);
                insert.setString(5, profilePic);
                insert.executeUpdate();

                res.sendRedirect("login.jsp");

            } catch (Exception dbErr) {
                dbErr.printStackTrace();
                res.sendRedirect("register.jsp?error=true");
            }

        } catch (ServletException | IOException e) {
            e.printStackTrace();
            res.sendRedirect("register.jsp?error=true");
        }
    }
}
