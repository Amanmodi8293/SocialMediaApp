package controller;

import java.io.*;
import java.sql.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/UpdateProfileServlet")
@MultipartConfig(fileSizeThreshold = 1024 * 1024,  // 1MB
                 maxFileSize = 1024 * 1024 * 5,    // 5MB
                 maxRequestSize = 1024 * 1024 * 10) // 10MB
public class UpdateProfileServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession();
        Integer uid = (Integer) session.getAttribute("user_id");

        String name = req.getParameter("name");
        String bio = req.getParameter("bio");

        String fileName = null;

        try {
            Part filePart = req.getPart("profile_pic");

            if (filePart != null && filePart.getSize() > 0) {
                fileName = System.currentTimeMillis() + "_" + filePart.getSubmittedFileName();
                String uploadPath = getServletContext().getRealPath("/") + "uploads";
                File uploadDir = new File(uploadPath);
                if (!uploadDir.exists()) uploadDir.mkdir();

                filePart.write(uploadPath + File.separator + fileName);
            }

            try (Connection conn = DBConnection.getConnection()) {
                String sql = (fileName != null)
                        ? "UPDATE users SET name=?, bio=?, profile_pic=? WHERE id=?"
                        : "UPDATE users SET name=?, bio=? WHERE id=?";

                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, name);
                ps.setString(2, bio);
                if (fileName != null) {
                    ps.setString(3, "uploads/" + fileName);
                    ps.setInt(4, uid);
                } else {
                    ps.setInt(3, uid);
                }

                ps.executeUpdate();
                ps.close();

                // update session name
                session.setAttribute("user_name", name);
                res.sendRedirect("profile.jsp");
            }

        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().println("Profile update failed. Error: " + e.getMessage());
        }
    }
}
