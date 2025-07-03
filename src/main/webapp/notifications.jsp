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
    <title>Notifications</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        html, body {
            height: 100%;
            overflow: auto;
            scrollbar-width: none;      
            -ms-overflow-style: none;     
        }

    html::-webkit-scrollbar,
    body::-webkit-scrollbar {
        display: none;                
    }

    * {
        user-select: none;
        -webkit-user-select: none;
        -moz-user-select: none;
        -ms-user-select: none;
    }

    .container {
        margin-top: 40px;
        max-width: 700px;
    }

    .notif-item {
        background-color: #fff;
        padding: 15px 20px;
        margin-bottom: 10px;
        border-radius: 10px;
        box-shadow: 0 0 5px rgba(0,0,0,0.05);
        display: flex;
        align-items: center;
        cursor: pointer;
    }

    .notif-item.unseen {
        border-left: 5px solid #0d6efd;
        background-color: #eef4ff;
    }

    .notif-item img {
        width: 48px;
        height: 48px;
        border-radius: 50%;
        object-fit: cover;
        margin-right: 15px;
    }

    .notif-text {
        flex: 1;
    }

    .notif-text p {
        margin: 0;
    }

    .notif-time {
        font-size: 0.8rem;
        color: #666;
    }
</style>


</head>
<body>

<jsp:include page="navbar.jsp" />

<div class="container">
    <h4 class="mb-4">🔔 Notifications</h4>

<%
    try {
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement(
            "SELECT n.id, n.message, n.is_seen, n.created_at, u.name, u.profile_pic, p.content, r.caption, n.type " +
            "FROM notifications n " +
            "JOIN users u ON n.user_id = u.id " +
            "LEFT JOIN posts p ON n.post_id = p.id " +
            "LEFT JOIN reels r ON n.reel_id = r.id " +
            "WHERE n.receiver_id = ? ORDER BY n.created_at DESC"
        );
        ps.setInt(1, uid);
        ResultSet rs = ps.executeQuery();

        boolean found = false;
        while (rs.next()) {
            found = true;
            int notifId = rs.getInt("id");
            String message = rs.getString("message");
            String senderName = rs.getString("name");
            String senderPic = rs.getString("profile_pic");
            String postContent = rs.getString("content");
            String reelCaption = rs.getString("caption");
            String createdAt = rs.getString("created_at");
            boolean isSeen = rs.getBoolean("is_seen");
            String type = rs.getString("type");

            String extraContent = "";
            if (type.equals("like") || type.equals("comment")) {
                extraContent = postContent != null ? postContent : "";
            } else if (type.equals("reel_like") || type.equals("reel_comment")) {
                extraContent = reelCaption != null ? reelCaption : "";
            }
            if (senderPic == null || senderPic.trim().isEmpty()) senderPic = "images/default-avatar.png";
%>
    <div class="notif-item <%= !isSeen ? "unseen" : "" %>" onclick="markAsSeen(<%= notifId %>, this)">
        <img src="<%=request.getContextPath() + "/" + senderPic%>" alt="User" />
        <div class="notif-text">
            <p><strong><%= senderName %></strong> <%= message %></p>
            <% if (!extraContent.isEmpty()) { %>
                <p class="text-muted">"<%= extraContent %>"</p>
            <% } %>
            <div class="notif-time"><%= createdAt %></div>
        </div>
    </div>
<%
        }
        rs.close(); ps.close(); conn.close();

        if (!found) {
%>
    <div class="alert alert-info">No notifications yet!</div>
<%
        }
    } catch (Exception e) {
        out.println("<div class='alert alert-danger'>Error loading notifications: " + e.getMessage() + "</div>");
    }
%>


</div>
<script>
    function markAsSeen(id, elem) {
        fetch("MarkNotificationsSeenServlet", {
            method: "POST",
            headers: { "Content-Type": "application/x-www-form-urlencoded" },
            body: "notification_id=" + id
        }).then(() => {
            elem.classList.remove("unseen");
        });
    }
</script>

</body>
</html>
