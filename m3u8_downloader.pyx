# m3u8_downloader.pyx
import subprocess
import re
import requests
from tqdm import tqdm
from concurrent.futures import ThreadPoolExecutor, as_completed

# 下载单个 TS 文件
def download_ts_file(str ts_url, str output_directory):
    """下载单个 TS 文件"""
    try:
        response = requests.get(ts_url, stream=True)
        response.raise_for_status()
        
        ts_file_name = ts_url.split("/")[-1]
        output_file_path = f"{output_directory}/{ts_file_name}"

        with open(output_file_path, 'wb') as ts_file:
            for chunk in response.iter_content(chunk_size=8192):
                ts_file.write(chunk)

        return output_file_path
    except Exception as e:
        print(f"下载失败: {ts_url}, 错误: {e}")
        return None

# 下载 M3U8 文件并将其存储为 MP4 文件
def download_m3u8_to_mp4(str m3u8_url, str output_file, str output_directory):
    """下载 M3U8 文件并将其存储为 MP4 文件"""
    user_agent = 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36'
    
    command = [
        'ffmpeg',
        '-i', m3u8_url,
        '-c', 'copy',
        output_file,
        '-stats',
        '-loglevel', 'info'
    ]

    # 获取 M3U8 内容
    try:
        response = requests.get(m3u8_url, headers={'User-Agent': user_agent})
        response.raise_for_status()
        m3u8_content = response.text

        print(f"M3U8 内容:\n{m3u8_content}")  # 调试信息

        # 解析 TS 文件 URLs
        ts_urls = []
        for line in m3u8_content.splitlines():
            if line and not line.startswith('#'):
                full_ts_url = line if line.startswith('http') else f"{m3u8_url.rsplit('/', 1)[0]}/{line}"
                ts_urls.append(full_ts_url)
                print(f"解析到的 TS URL: {full_ts_url}")  # 调试信息

        # 使用线程池下载 TS 文件
        with ThreadPoolExecutor(max_workers=5) as executor:
            futures = {executor.submit(download_ts_file, ts_url, output_directory): ts_url for ts_url in ts_urls}
            for future in tqdm(as_completed(futures), total=len(ts_urls), desc="下载进度"):
                future.result()  # 等待每个下载完成

        # 使用 ffmpeg 合并 TS 文件并显示进度条
        process = subprocess.Popen(command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)

        # 读取 ffmpeg 的标准输出和错误输出
        for line in process.stderr:
            if "time=" in line:
                # 提取当前时间
                time_str = line.split("time=")[1].split(" ")[0]
                print(f"合并进度: {time_str}")  # 输出当前进度

        process.wait()  # 等待 ffmpeg 进程结束
        print(f"{output_file} 下载完成！")
    except Exception as e:
        print(f"下载失败: {e}")

def download_with_progress(str m3u8_url, str output_file, str output_directory):
    """下载 M3U8 文件并显示进度条"""
    download_m3u8_to_mp4(m3u8_url, output_file, output_directory)