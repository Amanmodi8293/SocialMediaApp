<%@ page import="java.sql.*, util.DBConnection" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    Integer uid = (Integer) session.getAttribute("user_id");
    if (uid == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String profilePic = "default.png";
    try {
        Connection conn = DBConnection.getConnection();
        PreparedStatement ps = conn.prepareStatement("SELECT profile_pic FROM users WHERE id=?");
        ps.setInt(1, uid);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            String pic = rs.getString("profile_pic");
            if (pic != null && !pic.trim().isEmpty()) profilePic = pic;
        }
        rs.close(); ps.close(); conn.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!-- 🔊 Audio for Notifications -->
<audio id="notifSound" src="assest/move.mp3" preload="auto"></audio>
<audio id="messageSound" src="assest/move.mp3" preload="auto"></audio>

<!-- 🌐 Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary fixed-top">
    <div class="container-fluid">
        <a class="navbar-brand fw-bold" href="home.jsp">SocialConnect</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navContent">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navContent">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item"><a class="nav-link" href="home.jsp">Home</a></li>
                <li class="nav-item"><a class="nav-link" href="create_post.jsp">Create Post</a></li>
                <li class="nav-item"><a class="nav-link" href="upload_reel.jsp">Upload Reel</a></li>
                <li class="nav-item"><a class="nav-link" href="explore_users.jsp">Explore</a></li>
                <li class="nav-item"><a class="nav-link" href="reels.jsp">Reels</a></li>
            </ul>

            <ul class="navbar-nav ms-auto">
                <li class="nav-item me-3">
                    <a class="nav-link position-relative" href="notifications.jsp">
                        🔔
                        <span id="notifBadge" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none">0</span>
                    </a>
                </li>
                <li class="nav-item me-3">
                    <a class="nav-link position-relative" href="chat_list.jsp">
                        💬
                        <span id="messageBadge" class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger d-none">0</span>
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle d-flex align-items-center" href="#" role="button" data-bs-toggle="dropdown">
                        <img src="<%=request.getContextPath() + "/" + profilePic%>" class="rounded-circle me-2" style="width: 32px; height: 32px; object-fit: cover;">
                    </a>
                    <ul class="dropdown-menu dropdown-menu-end">
                        <li><a class="dropdown-item" href="profile.jsp">My Profile</a></li>
                        <li><a class="dropdown-item" href="edit_profile.jsp">Edit Profile</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item" href="LogoutServlet">Logout</a></li>
                    </ul>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- ✅ Space below fixed navbar -->
<style>
body {
    padding-top: 56px; /* adjust if navbar height changes */
}
</style>

<!-- 📱 Responsive Navbar Styling for Mobile -->
<style>
@media (max-width: 991.98px) {
    .navbar-nav .nav-link {
        margin: 6px 0;
        padding: 10px 15px;
        border-radius: 8px;
        background-color: rgba(255, 255, 255, 0.2);
        color: #fff !important;
        text-align: center;
        transition: all 0.3s ease;
    }

    .navbar-nav .nav-link:hover {
        background-color: rgba(255, 255, 255, 0.3);
        transform: scale(1.02);
    }

    .navbar-nav .nav-item {
        width: 100%;
    }
}
</style>

<!-- Bootstrap Bundle -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>

<!-- 🔁 Add your notification JS here after this -->

<script>
let lastNotifCount = 0;
let lastMessageCount = 0;

let hiddenNotifStartCount = 0;
let pendingNotifPlays = 0;

let justPlayedDelayed = false;

const notifSound = document.getElementById("notifSound");
const messageSound = document.getElementById("messageSound");

let audioUnlocked = false;
let suppressSound = false;

//✅ Check if user previously enabled audio
if (localStorage.getItem("audio_enabled") === "true") {
    // Try playing silently to verify if allowed
    notifSound.play().then(() => {
        notifSound.pause();
        notifSound.currentTime = 0;
        audioUnlocked = true;
        console.log("✅ Audio auto-enabled after page reload");
    }).catch(err => {
        audioUnlocked = false;
        console.warn("🚫 Audio auto-play blocked after reload, needs interaction again:", err);
    });
}


//✅ Unlock audio manually
function enableAudio() {
    try {
        Promise.all([
            notifSound.play().then(() => notifSound.pause()).catch(err => {
                console.log("🔇 Notif sound block:", err);
                throw err;
            }),
            messageSound.play().then(() => messageSound.pause()).catch(err => {
                console.log("🔇 Msg sound block:", err);
                throw err;
            })
        ])
        .then(() => {
            audioUnlocked = true;
            localStorage.setItem("audio_enabled", "true");
            console.log("🔓 Audio manually unlocked by user");
        })
        .catch(() => {
            alert("⚠️ Please interact with the page (like click) to enable sound.");
        });
    } catch (e) {
        console.log("❌ Unexpected error:", e);
    }
}


// 🛑 Suppress sound on anchor clicks
document.querySelectorAll('a').forEach(link => {
    link.addEventListener('click', () => {
        suppressSound = true;
        setTimeout(() => suppressSound = false, 1000);
    });
});

// 🔊 Play sound multiple times
function playMultipleSounds(audio, label, times) {
    if (!audioUnlocked || suppressSound || times <= 0) {
        console.log(`🚫 Skipped sound: ${label}`);
        return;
    }

    for (let i = 0; i < times; i++) {
        setTimeout(() => {
            const clone = audio.cloneNode();
            clone.play()
                .then(() => console.log(`✅ ${label} sound ${i + 1}/${times} played`))
                .catch(err => console.log(`❌ Failed to play ${label} sound ${i + 1}/${times}`, err));
        }, i * 400);
    }
}

// 🔄 Handle tab visibility
document.addEventListener("visibilitychange", () => {
    if (document.visibilityState === "hidden") {
        hiddenNotifStartCount = lastNotifCount;
        console.log("😴 Tab hidden. Notif count saved:", hiddenNotifStartCount);
    }

    if (document.visibilityState === "visible") {
        if (pendingNotifPlays > 0) {
            console.log(`👁 Tab active - playing ${pendingNotifPlays} delayed notification sound(s)`);
            playMultipleSounds(notifSound, "🔔 Delayed Notification", pendingNotifPlays);
            justPlayedDelayed = true;
            setTimeout(() => justPlayedDelayed = false, 1500); // 🕒 Prevent immediate replay
            pendingNotifPlays = 0;
        }
    }
});

let firstRun = true;

function fetchBadges() {
    fetch("FetchUnreadMessageCountServlet")
        .then(res => res.text())
        .then(count => {
            const badge = document.getElementById("messageBadge");
            const newCount = parseInt(count);
            console.log("💬 Message count:", newCount, "Last:", lastMessageCount);
            if (newCount > 0) {
                badge.textContent = newCount;
                badge.classList.remove("d-none");
                const diff = newCount - lastMessageCount;
                if (!firstRun && diff > 0) {
                    playMultipleSounds(messageSound, "💬 Message", diff);
                }
            } else {
                badge.classList.add("d-none");
            }
            lastMessageCount = newCount;
        });

    fetch("FetchNotificationsServlet")
        .then(res => res.text())
        .then(count => {
            const badge = document.getElementById("notifBadge");
            const newCount = parseInt(count);
            console.log("🔔 Notification count:", newCount, "Last:", lastNotifCount);

            const diff = newCount - lastNotifCount;

            if (newCount > 0) {
                badge.textContent = newCount;
                badge.classList.remove("d-none");

                if (!firstRun) {
                    if (document.visibilityState === "visible") {
                        if (diff > 0 && !justPlayedDelayed) {
                            playMultipleSounds(notifSound, "🔔 Notification", diff);
                        }
                    } else {
                        const delayCount = newCount - hiddenNotifStartCount;
                        if (delayCount > 0) {
                            console.log(`⏳ Tab not visible - delaying ${delayCount} notification sound(s)`);
                            pendingNotifPlays = delayCount;
                        }
                    }
                }
            } else {
                badge.classList.add("d-none");
            }

            lastNotifCount = newCount;
        });

    // ✅ After first run, disable sound suppression
    firstRun = false;
}

// First Fetch — no sound on first load
fetchBadges();
setInterval(fetchBadges, 1000);

</script>

