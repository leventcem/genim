import os
from subprocess import Popen

import json
  
# Opening JSON file
f = open('whisper/vocab.json')
  
# returns JSON object as 
# a dictionary
vocab = json.load(f)
  
def get_audio():
  if os.path.exists("prompt_request.wav"):
    return stt()
  display(HTML(AUDIO_HTML))
  data = eval_js("data")
  binary = b64decode(data.split(',')[1])
  
  process = (ffmpeg
    .input('pipe:0')
    .output('pipe:1', format='wav')
    .run_async(pipe_stdin=True, pipe_stdout=True, pipe_stderr=True, quiet=True, overwrite_output=True)
  )
  output, err = process.communicate(input=binary)
  
  riff_chunk_size = len(output) - 8
  # Break up the chunk size into four bytes, held in b.
  q = riff_chunk_size
  b = []
  for i in range(4):
      q, r = divmod(q, 256)
      b.append(r)

  # Replace bytes 4:8 in proc.stdout with the actual size of the RIFF chunk.
  riff = output[:4] + bytes(b) + output[8:]

  sr, audio = wav_read(io.BytesIO(riff))

  return audio, sr
model = Popen(["whisper/tf_model_tiny.h5"])
def stt():
    
    if not os.path.exists("prompt_request.wav"):
        return "no wav"
    model = whisper.load_model("medium.en")
    result = model.transcribe("prompt_request.wav")

    prompt = result["text"]
    print(prompt)
    return prompt