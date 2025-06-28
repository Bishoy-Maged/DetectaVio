<?php
require_once 'connect.php';

header("Content-Type: application/json");

// Base URL pointing to the root directory where your videos are stored
$base_url = "https://77a8-102-184-16-246.ngrok-free.app/Graduation%20project/Backend/Login/";
$base_dir = __DIR__ . "/"; // Adjust if your videos are in a subfolder

function convert_webm_to_mp4($webm_path, $mp4_path) {
    if (file_exists($webm_path) && !file_exists($mp4_path)) {
        // Run ffmpeg conversion
        $cmd = "ffmpeg -i " . escapeshellarg($webm_path) . " -c:v libx264 -c:a aac " . escapeshellarg($mp4_path) . " -y 2>&1";
        $output = [];
        $return_var = 0;
        exec($cmd, $output, $return_var);
        if ($return_var !== 0) {
            file_put_contents(__DIR__ . '/ffmpeg_errors.log', date('Y-m-d H:i:s') . " - Error converting $webm_path to $mp4_path:\n" . implode("\n", $output) . "\n\n", FILE_APPEND);
        }
    }
}

// SQL query to fetch video details with id instead of uploaded_by
$query = "SELECT v.video_id, v.video_name, v.location, v.id, a.alert_time
          FROM video v
          LEFT JOIN alerts_table a ON v.video_id = a.video_id
          ORDER BY a.alert_time DESC";

$result = mysqli_query($conn, $query);
$videos = [];

if ($result) {
    while ($row = mysqli_fetch_assoc($result)) {
        $location = $row["location"];
        $webm_path = $base_dir . $location;
        $mp4_location = preg_replace('/\\.webm$/i', '.mp4', $location);
        $mp4_path = $base_dir . $mp4_location;

        // Convert if needed (only if .webm exists and .mp4 does not)
        convert_webm_to_mp4($webm_path, $mp4_path);

        // Prefer .mp4 if it exists, else fallback to .webm
        if (file_exists($mp4_path)) {
            $video_url = $base_url . $mp4_location;
        } else {
            $video_url = $base_url . $location;
        }

        $videos[] = [
            "video_id"   => $row["video_id"],
            "video_name" => $row["video_name"],
            "video_url"  => $video_url,
            "id"         => $row["id"],  // Changed from uploaded_by to id
            "alert_time" => $row["alert_time"]
        ];
    }
    echo json_encode(["status" => "success", "videos" => $videos]);
} else {
    // Log DB error
    file_put_contents(__DIR__ . '/ffmpeg_errors.log', date('Y-m-d H:i:s') . " - DB Error: " . mysqli_error($conn) . "\n", FILE_APPEND);
    echo json_encode(["status" => "error", "message" => "Failed to fetch videos."]);
}
?>
