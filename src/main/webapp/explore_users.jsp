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
    <title>Explore Users</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        html, body {
            height: 100%;
            background-color: #f4f6f9;
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
        }

        .container {
            margin-top: 40px;
            max-width: 800px;
        }

        .card {
            margin-bottom: 20px;
            border-radius: 12px;
            box-shadow: 0 0 6px rgba(0, 0, 0, 0.1);
            padding: 15px 20px;
        }

        .user-info {
            display: flex;
            align-items: center;
            gap: 15px;
            flex: 1;
        }

        .user-info img {
            width: 60px;
            height: 60px;
            object-fit: cover;
            border-radius: 50%;
            border: 2px solid #0d6efd;
        }

        .user-details {
            display: flex;
            flex-direction: column;
        }

        .user-name {
            font-weight: 600;
            font-size: 1.1rem;
            margin-bottom: 2px;
        }

        .user-bio {
            font-size: 0.9rem;
            color: #6c757d;
            font-style: italic;
        }

        .card-body {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            justify-content: space-between;
            gap: 10px;
        }

        .action-buttons {
            display: flex;
            gap: 8px;
            flex-wrap: wrap;
        }

        .btn-follow {
            border-radius: 20px;
            min-width: 85px;
        }

        @media (max-width: 576px) {
            .card-body {
                flex-direction: column;
                align-items: flex-start;
            }

            .action-buttons {
                width: 100%;
                justify-content: flex-start;
            }
        }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp" />

<div class="container">
    <h3 class="text-center mb-4">Explore Users</h3>

    <%
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement("SELECT id, name, bio, profile_pic FROM users WHERE id != ?");
            ps.setInt(1, uid);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                int userId = rs.getInt("id");
                String name = rs.getString("name");
                String bio = rs.getString("bio");
                String pic = rs.getString("profile_pic");
                if (pic == null || pic.trim().isEmpty()) pic = "default.png";

                boolean isFollowing = false;
                PreparedStatement followCheck = conn.prepareStatement("SELECT id FROM follows WHERE follower_id=? AND following_id=?");
                followCheck.setInt(1, uid);
                followCheck.setInt(2, userId);
                ResultSet followRs = followCheck.executeQuery();
                if (followRs.next()) isFollowing = true;
                followRs.close(); followCheck.close();
    %>

    <div class="card">
        <div class="card-body">
            <div class="user-info">
                <img src="<%=request.getContextPath() + "/" + pic%>" alt="User">
                <div>
                    <p class="user-name"><%= name %></p>
                    <p class="user-bio"><%= bio %></p>
                </div>
            </div>
            <div>
                <a href="profile.jsp?user_id=<%= userId %>" class="btn btn-outline-primary btn-sm me-2">View</a>
                <% if (userId != uid) { %>
                    <button class="btn btn-sm btn-follow <%= isFollowing ? "btn-success" : "btn-outline-primary" %>" 
                            onclick="toggleFollow(<%= userId %>, this)">
                        <%= isFollowing ? "Following" : "Follow" %>
                    </button>
                <% } %>
            </div>
        </div>
    </div>

    <%
            }

            rs.close();
            ps.close();
            conn.close();
        } catch (Exception e) {
            out.println("<div class='text-danger'>Error loading users: " + e.getMessage() + "</div>");
        }
    %>
</div>

<!-- 🔁 JavaScript Follow Toggle -->
<script>
function toggleFollow(followingId, btn) {
    fetch("FollowServlet", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded" },
        body: "following_id=" + followingId
    })
    .then(res => res.text())
    .then(data => {
        if (data === "followed") {
            btn.textContent = "Following";
            btn.classList.remove("btn-outline-primary");
            btn.classList.add("btn-success");
        } else if (data === "unfollowed") {
            btn.textContent = "Follow";
            btn.classList.remove("btn-success");
            btn.classList.add("btn-outline-primary");
        } else {
            alert("Something went wrong.");
        }
    })
    .catch(err => {
        console.error("Error:", err);
        alert("Failed to connect to server.");
    });
}
</script>

</body>
</html>
