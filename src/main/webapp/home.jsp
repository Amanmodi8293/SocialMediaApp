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
    <title>Home - Feed</title>
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

        .post-card {
            border: 1px solid #ccc;
            border-radius: 10px;
            padding: 15px;
            margin-bottom: 20px;
            background-color: #fff;
        }

        .post-img {
            width: 100%;
            height: auto;
            max-height: 450px;
            object-fit: contain;
            border-radius: 8px;
            display: block;
            margin: auto;
        }

        .poster-info {
            font-weight: bold;
        }

        .caption {
            margin-top: 10px;
        }
    </style>
</head>
<body>

<jsp:include page="navbar.jsp" />

<div class="container mt-4">
    <h4 class="mb-4">Latest Posts</h4>
    <div class="row">
        <%
            try {
                Connection conn = DBConnection.getConnection();

                PreparedStatement ps = conn.prepareStatement(
                    "SELECT p.id, p.user_id, p.image_path, p.content, p.created_at, u.name, u.profile_pic " +
                    "FROM posts p JOIN users u ON p.user_id = u.id ORDER BY p.created_at DESC"
                );
                ResultSet rs = ps.executeQuery();
                while (rs.next()) {
                    int postId = rs.getInt("id");
                    String image = rs.getString("image_path");
                    String caption = rs.getString("content");
                    String time = rs.getString("created_at");
                    String name = rs.getString("name");
                    String profilePic = rs.getString("profile_pic");
                    if (profilePic == null || profilePic.trim().equals("")) profilePic = "default.png";

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
                    if (uid != null) {
                        PreparedStatement likedStmt = conn.prepareStatement("SELECT * FROM likes WHERE post_id=? AND user_id=?");
                        likedStmt.setInt(1, postId);
                        likedStmt.setInt(2, uid);
                        ResultSet likedRs = likedStmt.executeQuery();
                        liked = likedRs.next();
                        likedRs.close();
                        likedStmt.close();
                    }
        %>
        <div class="col-md-6 offset-md-3">
            <div class="post-card">
                <div class="d-flex align-items-center mb-2">
                    <img src="<%=request.getContextPath() + "/" + profilePic%>" class="rounded-circle me-2" width="40" height="40">
                    <div>
                        <div class="poster-info"><%= name %></div>
                        <div class="text-muted" style="font-size: 12px;"><%= time %></div>
                    </div>
                </div>
                <img src="<%=request.getContextPath() + "/" + image%>" class="post-img" alt="Post Image">
                <div class="caption"><%= caption %></div>

                <div class="d-flex align-items-center gap-4 mt-2">
                    <div class="d-flex align-items-center">
                        <button class="btn btn-sm btn-outline-danger action-btn <%= liked ? "text-danger" : "" %>"
                                onclick="toggleLike(<%= postId %>, this)">
                            ♥️
                        </button>
                        <span class="ms-1 fw-bold" id="likeCount-<%= postId %>"><%= likeCount %></span>
                    </div>

                    <div class="d-flex align-items-center">
                        <button class="btn btn-sm btn-outline-secondary" onclick="openComments(<%= postId %>)">
                            💬
                        </button>
                        <span class="ms-1 fw-bold" id="commentCount-<%= postId %>"><%= commentCount %></span>
                    </div>
                </div>
            </div>
        </div>
        <%
                }
                rs.close();
                ps.close();
                conn.close();

            } catch (Exception e) {
                out.println("<div class='text-danger'>Error: " + e.getMessage() + "</div>");
            }
        %>
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
