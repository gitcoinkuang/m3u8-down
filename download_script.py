import os
import platform
from m3u8_downloader import download_with_progress

def clean_ts_files(directory):
    """删除指定目录下的所有 TS 文件"""
    try:
        print("正在清理 TS 文件...")
        # 删除 TS 文件
        for filename in os.listdir(directory):
            file_path = os.path.join(directory, filename)
            if os.path.isfile(file_path):
                os.remove(file_path)  # 删除文件
                print(f"删除文件: {file_path}")
    except Exception as e:
        print(f"清理失败: {e}")

if __name__ == "__main__":
    m3u8_url = "你的M3U8文件URL"  # 替换为实际的 M3U8 文件 URL
    output_file = "output.mp4"  # 输出的 MP4 文件名
    output_directory = "./ts_files"  # 下载 TS 文件的目录

    # 下载 M3U8 文件并存储为 MP4
    download_with_progress(m3u8_url, output_file, output_directory)

    # 清理 TS 文件
    if os.path.exists(output_directory):
        clean_ts_files(output_directory)