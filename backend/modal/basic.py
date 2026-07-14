import modal

app = modal.App("hello-world")


import subprocess


@app.function()
@modal.web_server(8000)
def my_file_server():
    subprocess.Popen("python -m http.server -d / 8000", shell=True)
