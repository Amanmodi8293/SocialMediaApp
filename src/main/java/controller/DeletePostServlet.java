package controller;

import java.io.*;
import java.sql.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/DeletePostServlet")
public class DeletePostServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        HttpSession session = req.getSession();
        Integer uid = (Integer) session.getAttribute("user_id");
        if (uid == null) {
            res.sendRedirect("login.jsp");
            return;
        }

        int postId = Integer.parseInt(req.getParameter("post_id"));

        try (Connection conn = DBConnection.getConnection()) {
            // Fetch image to delete
            PreparedStatement getPost = conn.prepareStatement("SELECT image_path FROM posts WHERE id=? AND user_id=?");
            getPost.setInt(1, postId);
            getPost.setInt(2, uid);
            ResultSet rs = getPost.executeQuery();

            if (!rs.next()) {
                res.getWriter().write("Invalid post or unauthorized.");
                return;
            }

            String image = rs.getString("image_path");
            rs.close(); getPost.close();

            // Delete post
            PreparedStatement del = conn.prepareStatement("DELETE FROM posts WHERE id=? AND user_id=?");
            del.setInt(1, postId);
            del.setInt(2, uid);
            del.executeUpdate();
            del.close();

            // Delete image file
            File imgFile = new File(req.getServletContext().getRealPath("/uploads/" + image));
            if (imgFile.exists()) imgFile.delete();

            res.sendRedirect("profile.jsp");
        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().write("Error deleting post: " + e.getMessage());
        }
    }
}
