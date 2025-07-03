package controller;

import java.io.*;
import java.nio.file.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import util.DBConnection;

@WebServlet("/EditPostServlet")
@MultipartConfig
public class EditPostServlet extends HttpServlet {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	protected void doPost(HttpServletRequest req, HttpServletResponse res) throws IOException {
		HttpSession session = req.getSession();
		Integer uid = (Integer) session.getAttribute("user_id");
		if (uid == null) {
			res.sendRedirect("login.jsp");
			return;
		}

		int postId = Integer.parseInt(req.getParameter("post_id"));
		String caption = req.getParameter("caption");
		Part imagePart;
		try {
			imagePart = req.getPart("image");

			String fileName = null;

			try (Connection conn = DBConnection.getConnection()) {
				// Get existing image
				PreparedStatement getPost = conn
						.prepareStatement("SELECT image_path FROM posts WHERE id=? AND user_id=?");
				getPost.setInt(1, postId);
				getPost.setInt(2, uid);
				ResultSet rs = getPost.executeQuery();

				if (!rs.next()) {
					res.getWriter().write("Invalid post or unauthorized.");
					return;
				}

				String oldImage = rs.getString("image_path");
				rs.close();
				getPost.close();

				if (imagePart != null && imagePart.getSize() > 0) {
					// Upload new image
					fileName = System.currentTimeMillis() + "_"
							+ Paths.get(imagePart.getSubmittedFileName()).getFileName();
					String uploadPath = req.getServletContext().getRealPath("/uploads") + File.separator + fileName;
					imagePart.write(uploadPath);

					// Delete old image file
					File oldFile = new File(req.getServletContext().getRealPath("/uploads/" + oldImage));
					if (oldFile.exists())
						oldFile.delete();
				} else {
					fileName = oldImage; // keep old image
				}

				PreparedStatement ps = conn
						.prepareStatement("UPDATE posts SET content=?, image_path=? WHERE id=? AND user_id=?");
				ps.setString(1, caption);
				ps.setString(2, fileName);
				ps.setInt(3, postId);
				ps.setInt(4, uid);
				ps.executeUpdate();
				ps.close();

				res.sendRedirect("profile.jsp");
			}
		} catch (IOException | ServletException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
			res.getWriter().write("Error updating post: " + e.getMessage());
		}
	}
}
