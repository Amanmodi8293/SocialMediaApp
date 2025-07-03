package controller;

import java.io.IOException;
import java.sql.*;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/CommentServlet")
public class CommentServlet extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doGet(HttpServletRequest req, HttpServletResponse res) throws IOException {
        res.setContentType("text/html;charset=UTF-8");

        String postIdStr = req.getParameter("post_id");
        if (postIdStr == null || postIdStr.trim().isEmpty()) {
            res.getWriter().println("<p class='text-danger'>Invalid post ID</p>");
            return;
        }

        int postId = Integer.parseInt(postIdStr);

        try (Connection conn = DBConnection.getConnection()) {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT c.content, u.name, u.profile_pic, c.created_at " +
                "FROM comments c JOIN users u ON c.user_id = u.id " +
                "WHERE c.post_id = ? ORDER BY c.created_at DESC"
            );
            ps.setInt(1, postId);
            ResultSet rs = ps.executeQuery();

            boolean hasComments = false;
            while (rs.next()) {
                hasComments = true;
                String name = rs.getString("name");
                String comment = rs.getString("content");
                String profile = rs.getString("profile_pic");
                if (profile == null || profile.trim().isEmpty()) profile = "default.png";
                String time = rs.getString("created_at");

                res.getWriter().println("<div class='mb-2'>" +
                        "<img src='" + req.getContextPath() + "/" + profile + "' width='30' height='30' class='rounded-circle me-2'>" +
                        "<strong>" + name + ":</strong> " +
                        "<span>" + comment + "</span><br>" +
                        "<small class='text-muted'>" + time + "</small>" +
                    "</div>");
            }

            if (!hasComments) {
                res.getWriter().println("<p class='text-muted'>No comments yet.</p>");
            }

        } catch (Exception e) {
            e.printStackTrace();
            res.getWriter().println("<p class='text-danger'>Error loading comments.</p>");
        }
    }
}
