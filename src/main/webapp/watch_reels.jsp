<%@ page import="java.sql.*, util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer uid = (Integer) session.getAttribute("user_id");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title>Watch Reels</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #f4f6f9;
            color: #000;
        }

        .container {
            margin-top: 40px;
        }

        .reel-card {
            background: #fff;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
            transition: transform 0.2s ease;
        }

        .reel-card:hover {
            transform: scale(1.02);
        }

        .reel-video {
            width: 100%;
            height: 300px;
            object-fit: cover;
        }

        .reel-caption {
            padding: 15px;
        }

        .reel-caption h6 {
            font-weight: bold;
            margin-bottom: 5px;
        }

        .reel-caption p {
            margin: 0;
            color: #555;
        }

        @media(max-width: 768px) {
            .reel-video {
                height: 200px;
            }
        }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp" />

<div class="container">
    <h3 class="text-center mb-4">🎬 Watch Reels</h3>
    <div class="row">
        <%
            try {
                Connection conn = DBConnection.getConnection();
                PreparedStatement ps = conn.prepareStatement("SELECT r.*, u.name FROM reels r JOIN users u ON r.user_id = u.id ORDER BY r.created_at DESC");
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    String video = rs.getString("video_url");
                    String caption = rs.getString("caption");
                    String name = rs.getString("name");
        %>
        <div class="col-md-4 mb-4">
            <div class="reel-card">
                <video class="reel-video" controls>
                    <source src="uploads/<%= video %>" type="video/mp4">
                    Your browser does not support video.
                </video>
                <div class="reel-caption">
                    <h6>👤 <%= name %></h6>
                    <p><%= caption %></p>
                </div>
            </div>
        </div>
        <%
                }
                rs.close(); ps.close(); conn.close();
            } catch (Exception e) {
                out.println("<div class='text-danger'>Error loading reels: " + e.getMessage() + "</div>");
            }
        %>
    </div>
</div>

</body>
</html>
