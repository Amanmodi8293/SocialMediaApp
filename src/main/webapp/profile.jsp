<%@ page import="java.sql.*, util.DBConnection, java.text.SimpleDateFormat" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer sessionUid = (Integer) session.getAttribute("user_id");
    if (sessionUid == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    int profileId = sessionUid;
    String paramId = request.getParameter("user_id");
    if (paramId != null) {
        try {
            profileId = Integer.parseInt(paramId);
        } catch (Exception e) {
            profileId = sessionUid;
        }
    }

    String name = "", bio = "", profilePic = "default.png";
    boolean isFollowing = false;
    int followerCount = 0, followingCount = 0, postCount = 0;

    try {
        Connection conn = DBConnection.getConnection();

        PreparedStatement ps = conn.prepareStatement("SELECT name, bio, profile_pic FROM users WHERE id=?");
        ps.setInt(1, profileId);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            name = rs.getString("name");
            bio = rs.getString("bio");
            String pp = rs.getString("profile_pic");
            if (pp != null && !pp.trim().isEmpty()) profilePic = pp.trim();
        }
        rs.close(); ps.close();

        ps = conn.prepareStatement("SELECT COUNT(*) FROM follows WHERE following_id = ?");
        ps.setInt(1, profileId);
        rs = ps.executeQuery();
        if (rs.next()) followerCount = rs.getInt(1);
        rs.close(); ps.close();

        ps = conn.prepareStatement("SELECT COUNT(*) FROM follows WHERE follower_id = ?");
        ps.setInt(1, profileId);
        rs = ps.executeQuery();
        if (rs.next()) followingCount = rs.getInt(1);
        rs.close(); ps.close();

        if (profileId == sessionUid) {
            ps = conn.prepareStatement("SELECT COUNT(*) FROM posts WHERE user_id = ?");
            ps.setInt(1, sessionUid);
            rs = ps.executeQuery();
            if (rs.next()) postCount = rs.getInt(1);
            rs.close(); ps.close();
        }

        if (profileId != sessionUid) {
            PreparedStatement followCheck = conn.prepareStatement("SELECT id FROM follows WHERE follower_id=? AND following_id=?");
            followCheck.setInt(1, sessionUid);
            followCheck.setInt(2, profileId);
            ResultSet frs = followCheck.executeQuery();
            if (frs.next()) isFollowing = true;
            frs.close(); followCheck.close();
        }

        conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html>
<head>
    <title><%= name %> - Profile</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
         html, body { height: 100%; overflow: auto; scrollbar-width: none; -ms-overflow-style: none; }
         html::-webkit-scrollbar, body::-webkit-scrollbar { display: none; }
         * {user-select: none;  -webkit-user-select: none; -moz-user-select: none; -ms-user-select: none; }
        .profile-header { text-align: center; padding: 30px 0; }
        .profile-pic { width: 130px; height: 130px; object-fit: cover; border-radius: 50%; border: 3px solid #0d6efd; }
        .profile-name { font-size: 1.8rem; font-weight: bold; margin-top: 15px; }
        .bio-text { font-style: italic; color: #555; }
        .counts { margin-top: 10px; font-size: 1rem; color: #333; }
        .btn-actions { margin-top: 15px; }
        .post-card { margin-bottom: 25px; }
        .post-img { width: 100%; height: auto; max-height: 400px; object-fit: contain; border-radius: 10px; }
        .btn-follow { border-radius: 20px; }
        .post-header { display: flex; align-items: center; gap: 10px; margin-bottom: 8px; }
        .post-header img { width: 40px; height: 40px; border-radius: 50%; object-fit: cover; }
        .post-time { font-size: 0.8rem; color: gray; }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp" />

<div class="container">
    <div class="profile-header">
        <img src="<%=request.getContextPath() + "/" + profilePic%>" class="profile-pic" alt="Profile Picture">
        <div class="profile-name"><%= name %></div>
        <p class="bio-text"><%= bio %></p>

        <div class="counts">
            👥 Followers: <%= followerCount %> |
            🔁 Following: <%= followingCount %>
            <% if (profileId == sessionUid) { %> | 📝 Posts: <%= postCount %> <% } %>
        </div>

        <div class="btn-actions">
            <% if (profileId != sessionUid) { %>
                <a href="chat.jsp?receiver_id=<%= profileId %>" class="btn btn-primary btn-sm me-2">Message</a>
                <button class="btn btn-sm btn-follow <%= isFollowing ? "btn-success" : "btn-outline-primary" %>" 
                        onclick="toggleFollow(<%= profileId %>, this)">
                    <%= isFollowing ? "Following" : "Follow" %>
                </button>
            <% } else { %>
                <a href="edit_profile.jsp" class="btn btn-outline-info btn-sm">Edit Profile</a>
            <% } %>
        </div>
    </div>

    <div class="post-gallery mt-4">
        <div class="row">
            <%
                try {
                    Connection conn = DBConnection.getConnection();
                    PreparedStatement ps = conn.prepareStatement(
                    	    "SELECT posts.id, posts.image_path, posts.content, posts.created_at, users.name, users.profile_pic " +
                    	    "FROM posts JOIN users ON posts.user_id = users.id WHERE posts.user_id = ? ORDER BY posts.created_at DESC");
                    ps.setInt(1, profileId);
                    ResultSet rs = ps.executeQuery();

                    boolean found = false;
                    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

                    while (rs.next()) {
                        found = true;
                        int postId = rs.getInt("id");
                        String image = rs.getString("image_path");
                        String caption = rs.getString("content");
                        String postedTime = sdf.format(rs.getTimestamp("created_at"));
                        String posterName = rs.getString("name");
                        String posterPic = rs.getString("profile_pic");
                        if (posterPic == null || posterPic.trim().isEmpty()) posterPic = "default.png";
                        
                        PreparedStatement likeCountStmt = conn.prepareStatement("SELECT COUNT(*) FROM likes WHERE post_id=?");
                        likeCountStmt.setInt(1, postId);
                        ResultSet likeCountRs = likeCountStmt.executeQuery();
                        likeCountRs.next();
                        int likeCount = likeCountRs.getInt(1);
                        likeCountRs.close();
                        likeCountStmt.close();

                        PreparedStatement commentCountStmt = conn.prepareStatement("SELECT COUNT(*) FROM comments WHERE post_id=?");
                        commentCountStmt.setInt(1, postId);
                        ResultSet commentCountRs = commentCountStmt.executeQuery();
                        commentCountRs.next();
                        int commentCount = commentCountRs.getInt(1);
                        commentCountRs.close();
                        commentCountStmt.close();
                        
                        boolean liked = false;
                        if (sessionUid != null) {
                        	PreparedStatement likedStmt = conn.prepareStatement("SELECT * FROM likes WHERE post_id=? AND user_id=?");
                            likedStmt.setInt(1, postId);
                            likedStmt.setInt(2, sessionUid);
                            ResultSet likedRs = likedStmt.executeQuery();
                            liked = likedRs.next();
                            likedRs.close();
                            likedStmt.close();
                        }
            %>
            <div class="col-md-6 post-card">
                <div class="card">
                    <div class="card-body">
                        <div class="post-header">
                            <img src="<%=request.getContextPath() + "/" + posterPic%>" alt="User">
                            <div>
                                <strong><%= posterName %></strong><br>
                                <span class="post-time"><%= postedTime %></span>
                            </div>
                        </div>
                        <img src="<%=request.getContextPath() + "/" + image%>" class="post-img mb-2" alt="Post Image">
                        <p class="card-text"><%= caption %></p>

                        <div class="d-flex align-items-center gap-3">
			            <!-- Like/Comment Buttons Section -->
							<div class="d-flex align-items-center gap-4 mt-2">
							    <!-- Like Button -->
							    <div class="d-flex align-items-center">
							        <button class="btn btn-sm btn-outline-danger action-btn <%= liked ? "text-danger" : "" %>" 
							                onclick="toggleLike(<%= postId %>, this)">
							            ♥️
							        </button>
							        <span class="ms-1 fw-bold" id="likeCount-<%= postId %>"><%= likeCount %></span>
							    </div>
							
							    <!-- Comment Button -->
							    <div class="d-flex align-items-center">
							        <button class="btn btn-sm btn-outline-secondary" onclick="openComments(<%= postId %>)">
							            💬
							        </button>
							        <span class="ms-1 fw-bold" id="commentCount-<%= postId %>"><%= commentCount %></span>
							    </div>
							</div>

                            <% if (sessionUid == profileId) { %>
                                <a href="edit_post.jsp?post_id=<%= postId %>" class="btn btn-sm btn-outline-info ms-auto">📝 Edit</a>
                                <a href="DeletePostServlet?post_id=<%= postId %>" class="btn btn-sm btn-outline-danger">❌ Delete</a>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            <%
                    }

                    if (!found) {
                        out.println("<div class='text-center text-muted'>No posts yet.</div>");
                    }

                    rs.close(); ps.close(); conn.close();
                } catch (Exception e) {
                    out.println("<div class='text-danger'>Error loading posts: " + e.getMessage() + "</div>");
                }
            %>
        </div>
    </div>
</div>

<!-- Comment Modal -->
<div class="modal fade" id="commentModal" tabindex="-1" aria-labelledby="commentModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-scrollable modal-sm">
        <div class="modal-content bg-dark text-white">
            <div class="modal-header">
                <h5 class="modal-title" id="commentModalLabel">Comments</h5>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="commentsBody">
                <!-- Comments will load here -->
            </div>
            <div class="modal-footer">
                <input type="text" class="form-control" id="newComment" placeholder="Add a comment...">
                <button class="btn btn-primary" onclick="submitComment()">Post</button>
            </div>
        </div>
    </div>
</div>

<!-- JS for follow toggle -->
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

<script>
let currentPostId = null;

function toggleLike(postId, btn) {
    const xhr = new XMLHttpRequest();
    xhr.open("POST", "LikeServlet", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

    xhr.onload = function () {
        const res = this.responseText.trim();
        let countSpan = document.getElementById("likeCount-" + postId);

        if (res === "liked") {
            btn.classList.add("text-danger");
            countSpan.textContent = parseInt(countSpan.textContent || "0") + 1;
        } else if (res === "unliked") {
            btn.classList.remove("text-danger");
            countSpan.textContent = Math.max(0, parseInt(countSpan.textContent || "1") - 1);
        } else {
            alert("Error: " + res);
        }
    };

    xhr.onerror = function () {
        alert("Connection error during like.");
    };

    xhr.send("post_id=" + postId);
}

function openComments(postId) {
    currentPostId = postId;
    fetchComments(postId);
    const modal = new bootstrap.Modal(document.getElementById("commentModal"));
    modal.show();
}

function fetchComments(postId) {
    const xhr = new XMLHttpRequest();
    xhr.open("GET", "CommentServlet?post_id=" + postId, true);

    xhr.onload = function () {
        const container = document.getElementById("commentsBody");
        if (xhr.status === 200) {
            container.innerHTML = this.responseText.trim() || "<p class='text-muted'>No comments yet.</p>";
        } else {
            container.innerHTML = "<p class='text-danger'>Error loading comments.</p>";
        }
    };

    xhr.onerror = function () {
        document.getElementById("commentsBody").innerHTML = "<p class='text-danger'>Connection error.</p>";
    };

    xhr.send();
}

function submitComment() {
    const commentBox = document.getElementById("newComment");
    const comment = commentBox.value.trim();
    if (!comment) return;

    const xhr = new XMLHttpRequest();
    xhr.open("POST", "LoadAllCommentsServlet", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

    xhr.onload = function () {
        if (xhr.status === 200 && xhr.responseText.trim() === "success") {
            commentBox.value = "";
            fetchComments(currentPostId);
            const countSpan = document.getElementById("commentCount-" + currentPostId);
            if (countSpan) {
                countSpan.textContent = parseInt(countSpan.textContent || "0") + 1;
            }
        } else {
            alert("Error: " + xhr.responseText);
        }
    };

    xhr.onerror = function () {
        alert("Comment submission failed.");
    };

    xhr.send("post_id=" + currentPostId + "&comment=" + encodeURIComponent(comment));
}
</script>

</body>
</html>
