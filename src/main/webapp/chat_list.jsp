<%@ page import="java.sql.*, util.DBConnection"%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
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
<title>My Chats</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
<style>
body {
	background-color: #f4f6f9;
	margin: 0;
	padding: 0;
}

/* Responsive layout */
.chat-list-container {
	max-width: 800px;
	margin: 20px auto;
	padding: 10px;
}

.chat-user-card {
	padding: 15px;
	background-color: #fff;
	border-radius: 12px;
	margin-bottom: 12px;
	display: flex;
	align-items: center;
	justify-content: space-between;
	flex-wrap: wrap;
	box-shadow: 0 0 6px rgba(0, 0, 0, 0.08);
}

.chat-user-info {
	display: flex;
	align-items: center;
	gap: 15px;
	flex: 1;
	min-width: 200px;
}

.chat-user-info img {
	width: 50px;
	height: 50px;
	object-fit: cover;
	border-radius: 50%;
	border: 2px solid #0d6efd;
}

.chat-user-name {
	font-weight: 600;
	white-space: nowrap;
}

.btn-chat {
	border-radius: 20px;
	margin-top: 10px;
}
@media (min-width: 576px) {
	.btn-chat {
		margin-top: 0;
	}
}
</style>
</head>
<body>

<jsp:include page="navbar.jsp" />

<div class="chat-list-container">
	<h4 class="mb-4 text-center">💬 My Chats</h4>

	<%
	try {
	    Connection conn = DBConnection.getConnection();
	    PreparedStatement ps = conn.prepareStatement(
	        "SELECT DISTINCT CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END AS other_user_id " +
	        "FROM messages WHERE sender_id = ? OR receiver_id = ?"
	    );
	    ps.setInt(1, uid);
	    ps.setInt(2, uid);
	    ps.setInt(3, uid);
	    ResultSet rs = ps.executeQuery();

	    while (rs.next()) {
	        int otherId = rs.getInt("other_user_id");

	        PreparedStatement userPs = conn.prepareStatement("SELECT name, profile_pic FROM users WHERE id = ?");
	        userPs.setInt(1, otherId);
	        ResultSet userRs = userPs.executeQuery();

	        if (userRs.next()) {
	            String name = userRs.getString("name");
	            String pic = userRs.getString("profile_pic");
	            if (pic == null || pic.trim().isEmpty()) pic = "default.png";
	%>
	<div class="chat-user-card">
		<div class="chat-user-info">
			<img src="<%=request.getContextPath() + "/" + pic%>" alt="User" />
			<div class="chat-user-name"><%= name %></div>
		</div>
		<div>
			<a href="chat.jsp?receiver_id=<%= otherId %>"
				class="btn btn-primary btn-sm btn-chat position-relative open-chat-btn"
				data-user-id="<%= otherId %>">
				Open Chat
				<span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none">
					0
				</span>
			</a>
		</div>
	</div>
	<%
	        }
	        userRs.close();
	        userPs.close();
	    }

	    rs.close();
	    ps.close();
	    conn.close();
	} catch (Exception e) {
	    out.println("<div class='text-danger'>Error: " + e.getMessage() + "</div>");
	}
	%>
</div>

<script>
document.addEventListener("DOMContentLoaded", function () {
    fetch("FetchUnreadCountsServlet")
        .then(res => res.json())
        .then(data => {
            document.querySelectorAll(".open-chat-btn").forEach(btn => {
                const userId = btn.dataset.userId;
                const badge = btn.querySelector(".badge");
                if (data[userId] && parseInt(data[userId]) > 0) {
                    badge.textContent = data[userId];
                    badge.classList.remove("d-none");
                } else {
                    badge.classList.add("d-none");
                }
            });
        })
        .catch(err => console.error("❌ Error fetching unread counts:", err));
});
</script>

</body>
</html>
