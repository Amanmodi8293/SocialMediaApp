<%@ page import="java.sql.*, util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Watch Reels</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet" />
    <style>
        html, body {
            height: 100vh;
            margin: 0;
            padding: 0;
            overflow: hidden;
            scrollbar-width: none; /* Firefox */
        }
        html::-webkit-scrollbar, body::-webkit-scrollbar {
            display: none; /* Chrome */
        }

        * {
            user-select: none;
            -webkit-user-select: none;
            -moz-user-select: none;
            -ms-user-select: none;
        }

        .reel-container {
            height: 100vh;
            overflow-y: auto; /* Changed from scroll to auto */
            scroll-snap-type: y mandatory;
            padding-top: 56px;
            -webkit-overflow-scrolling: touch;
        }

        .reel-container::-webkit-scrollbar {
            display: none;
        }

        .reel-item {
            scroll-snap-align: start;
            height: 100vh;
            position: relative;
            margin: 0 auto;
            width: 100%;
            max-width: 408px;
        }
        
        @media (max-width: 408px) {
	    .reel-item {
	        padding-left: 0px !important;
	        padding-right: 0px !important;
	        margin-left: 0 !important;
	        margin-right: 0 !important;
	        width: 100% !important;
	    }
}
        .reel-video {
            height: 100%;
            width: 100%;
            object-fit: cover;
        }

        .video-controls {
            position: absolute;
            right: 15px;
            bottom: 200px;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 15px;
            z-index: 3;
        }

       .action-btn {
            background: none;
            border: none;
            color: white;
            font-size: 24px;
            text-shadow: 0 0 5px rgba(0, 0, 0, 0.5);
        }

        .action-count {
            color: white;
            font-size: 12px;
            font-weight: bold;
            text-align: center;
            margin-top: -8px;
        } 

        .reel-info {
            position: absolute;
            bottom: 70px;
            left: 15px;
            right: 15px;
            color: white;
            z-index: 3;
        }

        .pause-overlay {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            font-size: 64px;
            color: rgba(255,255,255,0.7);
            z-index: 4;
            pointer-events: none;
            opacity: 0;
            transition: opacity 0.3s ease;
        }

        .progress-bar {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 2px;
            background: rgba(255, 255, 255, 0.2);
            z-index: 2;
        }

        .progress {
            height: 100%;
            background: white;
            width: 0%;
            transition: width 0.1s linear;
        }

        .user-avatar img {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            object-fit: cover;
            margin-right: 10px;
        }

        .username { font-weight: bold; }
        .caption { margin-bottom: 5px; font-size: 14px; }
    </style>
</head>
<body>
<jsp:include page="navbar.jsp" />

<div class="reel-container">
    <%
    Integer uid = (Integer) session.getAttribute("user_id");
    Connection conn = DBConnection.getConnection();
    PreparedStatement ps = conn.prepareStatement(
            "SELECT r.id, r.video_path, r.caption, r.created_at, u.name, u.profile_pic FROM reels r JOIN users u ON r.user_id = u.id ORDER BY r.created_at DESC LIMIT 10");
    ResultSet rs = ps.executeQuery();

    while (rs.next()) {
        int reelId = rs.getInt("id");
        String filePath = rs.getString("video_path");
        String caption = rs.getString("caption");
        String uploader = rs.getString("name");
        String createdAt = rs.getString("created_at");
        String profileImg = rs.getString("profile_pic");
        if (profileImg == null || profileImg.trim().isEmpty()) {
            profileImg = "images/default-avatar.png";
        }
        
        PreparedStatement likeCountStmt = conn.prepareStatement("SELECT COUNT(*) FROM reel_likes WHERE reel_id=?");
        likeCountStmt.setInt(1, reelId);
        ResultSet likeCountRs = likeCountStmt.executeQuery();
        likeCountRs.next();
        int likeCount = likeCountRs.getInt(1);
        likeCountRs.close();
        likeCountStmt.close();

        PreparedStatement commentCountStmt = conn.prepareStatement("SELECT COUNT(*) FROM reel_comments WHERE reel_id=?");
        commentCountStmt.setInt(1, reelId);
        ResultSet commentCountRs = commentCountStmt.executeQuery();
        commentCountRs.next();
        int commentCount = commentCountRs.getInt(1);
        commentCountRs.close();
        commentCountStmt.close();

        boolean liked = false;
        if (uid != null) {
            PreparedStatement likedStmt = conn.prepareStatement("SELECT * FROM reel_likes WHERE reel_id=? AND user_id=?");
            likedStmt.setInt(1, reelId);
            likedStmt.setInt(2, uid);
            ResultSet likedRs = likedStmt.executeQuery();
            liked = likedRs.next();
            likedRs.close();
            likedStmt.close();
        }
        
        String shareUrl = request.getContextPath() + "/" + filePath;
    %>
    <div class="reel-item">
        <div class="progress-bar">
            <div class="progress"></div>
        </div>
        <video class="reel-video" playsinline autoplay>
            <source src="<%= shareUrl %>" type="video/mp4" />
        </video>

       <div class="video-controls">
    <div>
        <button class="action-btn <%= liked ? "text-danger" : "" %>" onclick="toggleLike(<%= reelId %>, this)">♥️</button>
        <div class="action-count"><%= likeCount %></div>
    </div>
    <div>
        <button class="btn btn-lg" onclick="openComments(<%= reelId %>)">💬</button>
        <div class="action-count" id="commentCount-<%= reelId %>"><%= commentCount %></div>
    </div>
    <button class="action-btn" 
            data-user="<%= uploader %>" 
            data-caption="<%= caption != null ? caption.replace("\"", "'").replace("\n", " ") : "" %>" 
            data-url="<%= filePath %>" 
            onclick="shareReel(this)">↗️</button>
</div>
        <div class="reel-info">
            <div class="user-info">
                <div class="user-avatar">
                    <img src="<%= request.getContextPath() + "/" + profileImg %>" alt="Profile" />
                </div>
                <div class="username"><%= uploader %></div>
            </div>
            <div class="caption"><%= caption %></div>
            <div class="audio">🎵 Original audio • <%= createdAt %></div>
        </div>
    </div>
    <%
    }
    rs.close();
    ps.close();
    conn.close();
    %>
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
// 🛑 Prevent swipe-to-refresh on mobile
let touchstartY = 0;
let isAtTop = false;

document.addEventListener("touchstart", function(e) {
    if (e.touches.length !== 1) return;
    touchstartY = e.touches[0].clientY;
    isAtTop = document.documentElement.scrollTop === 0 || document.body.scrollTop === 0;
}, { passive: false });

document.addEventListener("touchmove", function(e) {
    const currentY = e.touches[0].clientY;
    const isPullingDown = currentY - touchstartY > 10;
    if (isAtTop && isPullingDown) {
        e.preventDefault(); // Block pull-to-refresh
    }
}, { passive: false });
</script>


<script>
const reelItems = document.querySelectorAll(".reel-item");

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        const video = entry.target.querySelector("video");
        const progress = entry.target.querySelector(".progress");

        if (entry.isIntersecting) {
            video.currentTime = 0;
            video.play().catch(() => {});

            video.ontimeupdate = () => {
                progress.style.width = (video.currentTime / video.duration) * 100 + "%";
            };

            video.onended = () => {
                const next = entry.target.nextElementSibling;
                if (next && next.classList.contains("reel-item")) {
                    next.scrollIntoView({ behavior: 'smooth' });
                }
            };
        } else {
            video.pause();
            progress.style.width = '0%';
        }
    });
}, { threshold: 0.8 });

reelItems.forEach(item => {
    const video = item.querySelector("video");
    const overlay = document.createElement("div");
    overlay.className = "pause-overlay";
    overlay.innerHTML = "⏸";
    item.appendChild(overlay);

    video.addEventListener("click", () => {
        if (video.paused) {
            video.play();
            overlay.style.opacity = 0;
        } else {
            video.pause();
            overlay.style.opacity = 1;
            setTimeout(() => overlay.style.opacity = 0, 800);
        }
    });

    observer.observe(item);
});

function toggleLike(reelId, btn) {
    const xhr = new XMLHttpRequest();
    xhr.open("POST", "ToggleReelLikeServlet", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onload = function() {
        if (this.responseText === "liked") {
            btn.classList.add("text-danger");
            let countEl = btn.nextElementSibling;
            countEl.textContent = parseInt(countEl.textContent) + 1;
        } else if (this.responseText === "unliked") {
            btn.classList.remove("text-danger");
            let countEl = btn.nextElementSibling;
            countEl.textContent = parseInt(countEl.textContent) - 1;
        }
    };
    xhr.send("reel_id=" + reelId);
}

let currentReelId = null;

function openComments(reelId) {
    currentReelId = reelId;
    fetchComments(reelId);
    let modal = new bootstrap.Modal(document.getElementById('commentModal'));
    modal.show();
}

function fetchComments(reelId) {
    const xhr = new XMLHttpRequest();
    xhr.open("GET", "FetchReelCommentsServlet?reel_id=" + reelId, true);
    xhr.onload = function () {
        document.getElementById('commentsBody').innerHTML = this.responseText;
    };
    xhr.send();
}

function submitComment() {
    const commentText = document.getElementById("newComment").value.trim();
    if (commentText === "") return;

    const xhr = new XMLHttpRequest();
    xhr.open("POST", "AddReelCommentServlet", true);
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    xhr.onload = function () {
        document.getElementById("newComment").value = "";
        fetchComments(currentReelId);

        let countDiv = document.getElementById("commentCount-" + currentReelId);
        if (countDiv) {
            let currentCount = parseInt(countDiv.innerText);
            countDiv.innerText = currentCount + 1;
        }
    };
    xhr.send("reel_id=" + currentReelId + "&comment=" + encodeURIComponent(commentText));
}

function shareReel(btn) {
    const user = btn.getAttribute('data-user') || 'User';
    const caption = btn.getAttribute('data-caption') || '';
    const videoPath = btn.getAttribute('data-url') || '';
    
    // Create proper URL
    const shareUrl = window.location.origin + '<%= request.getContextPath() %>/' + videoPath.replace(/^\//, '');
    
    // Build share text safely without duplicates
    let shareText = user + "'s Reel";
    if (caption) {
        shareText += '\n\n' + caption.replace(/\\n/g, ' '); 
    }
    shareText += '\n\nWatch: ' + shareUrl.split('?')[0];

    // Try Web Share API first
    if (navigator.share) {
        navigator.share({
            title: user + "'s Reel",
            text: caption,
            url: shareUrl
        }).catch(() => {
            copyToClipboard(shareText);
        });
    } else {
        copyToClipboard(shareText);
    }
}

function copyToClipboard(text) {
    // Try modern clipboard API first
    if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(() => {
            showToast("Link copied!");
        }).catch(() => {
            legacyCopy(text);
        });
    } else {
        legacyCopy(text);
    }
}

function legacyCopy(text) {
    const textarea = document.createElement('textarea');
    textarea.value = text;
    document.body.appendChild(textarea);
    textarea.select();
    try {
        document.execCommand('copy');
        showToast("Copied!");
    } catch (err) {
        showToast("Failed to copy");
    }
    document.body.removeChild(textarea);
}

function copyToClipboard(text) {
    // Try modern clipboard API first
    if (navigator.clipboard) {
        navigator.clipboard.writeText(text).then(() => {
            showToast("Link copied to clipboard!");
        }, () => {
            legacyCopy(text);
        });
    } else {
        legacyCopy(text);
    }
}

function legacyCopy(text) {
    // Fallback method for older browsers
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.style.position = 'fixed';
    document.body.appendChild(textarea);
    textarea.select();
    
    try {
        const success = document.execCommand('copy');
        showToast(success ? "Link copied!" : "Failed to copy");
    } catch (err) {
        console.error('Failed to copy:', err);
        showToast("Please copy manually");
    }
    
    document.body.removeChild(textarea);
}

function showToast(message) {
    // Remove any existing toast first
    const oldToasts = document.querySelectorAll('.share-toast');
    oldToasts.forEach(toast => toast.remove());
    
    // Create new toast
    const toast = document.createElement("div");
    toast.className = "share-toast";
    toast.textContent = message;
    toast.style.position = "fixed";
    toast.style.bottom = "20px";
    toast.style.left = "50%";
    toast.style.transform = "translateX(-50%)";
    toast.style.padding = "12px 24px";
    toast.style.background = "rgba(0,0,0,0.9)";
    toast.style.color = "white";
    toast.style.borderRadius = "25px";
    toast.style.zIndex = "9999";
    toast.style.fontFamily = "Arial, sans-serif";
    toast.style.fontSize = "16px";
    toast.style.whiteSpace = "nowrap";
    toast.style.maxWidth = "80%";
    toast.style.textAlign = "center";
    toast.style.boxShadow = "0 2px 10px rgba(0,0,0,0.2)";
    toast.style.animation = "toast-fadein 0.5s, toast-fadeout 0.5s 2.5s forwards";
    
    document.body.appendChild(toast);
    
    // Auto remove after 3 seconds
    setTimeout(() => toast.remove(), 3000);
}

// Add styles for toast animation
const style = document.createElement('style');
style.textContent = `
@keyframes toast-fadein {
    from { opacity: 0; transform: translateX(-50%) translateY(20px); }
    to { opacity: 1; transform: translateX(-50%) translateY(0); }
}
@keyframes toast-fadeout {
    from { opacity: 1; transform: translateX(-50%) translateY(0); }
    to { opacity: 0; transform: translateX(-50%) translateY(-20px); }
}
`;
document.head.appendChild(style);
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>