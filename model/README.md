---
language: 
- en
tags:
- audio
- automatic-speech-recognition
- hf-asr-leaderboard
widget:
- example_title: Librispeech sample 1
  src: https://cdn-media.huggingface.co/speech_samples/sample1.flac
- example_title: Librispeech sample 2
  src: https://cdn-media.huggingface.co/speech_samples/sample2.flac
model-index:
- name: whisper-small.en
  results:
  - task:
      name: Automatic Speech Recognition
      type: automatic-speech-recognition
    dataset:
      name: LibriSpeech (clean)
      type: librispeech_asr
      config: clean
      split: test
      args: 
        language: en
    metrics:
    - name: Test WER
      type: wer
      value:
  - task:
      name: Automatic Speech Recognition
      type: automatic-speech-recognition
    dataset:
      name: LibriSpeech (other)
      type: librispeech_asr
      config: other
      split: test
      args: 
        language: en
    metrics:
    - name: Test WER
      type: wer
      value: 
pipeline_tag: automatic-speech-recognition
license: apache-2.0
---

# Whisper 

[OpenAI's Whisper](https://openai.com/blog/whisper/)

The Whisper model was proposed in [Robust Speech Recognition via Large-Scale Weak Supervision](https://cdn.openai.com/papers/whisper.pdf) by Alec Radford, Jong Wook Kim, Tao Xu, Greg Brockman, Christine McLeavey, Ilya Sutskever.

**Disclaimer**: Content from **this** model card has been written by the Hugging Face team, and parts of it were copy pasted from the original model card.


## Intro

The first paragraphs of the abstract read as follows : 

> We study the capabilities of speech processing systems trained simply to predict large amounts of transcripts of audio on the internet. When scaled to 680,000 hours of multilingual and multitask supervision, the resulting models generalize well to standard benchmarks and are often competitive with prior fully supervised results but in a zeroshot transfer setting without the need for any finetuning. 
> When compared to humans, the models approach their accuracy and robustness. We are releasing models and inference code to serve as a foundation for further work on robust speech processing.

The original code repository can be found [here](https://github.com/openai/whisper).

## Model details 

The Whisper models are trained for speech recognition and translation tasks, capable of transcribing speech audio into the text in the language it is spoken (ASR) as well as translated into English (speech translation). Researchers at OpenAI developed the models to study the robustness of speech processing systems trained under large-scale weak supervision. There are 9 models of different sizes and capabilities, summarised in the following table.

|  Size  | Parameters | English-only model | Multilingual model |  
|:------:|:----------:|:------------------:|:------------------:|
|  tiny  |    39 M    |         ✓          |         ✓          |
|  base  |    74 M    |         ✓          |         ✓          |
| small  |   244 M    |         ✓          |         ✓          |
| medium |   769 M    |         ✓          |         ✓          |
| large  |   1550 M   |                    |         ✓          |



## Model description 

Whisper is an auto-regressive automatic speech recognition encoder-decoder model that was trained on 680 000 hours of 16kHz sampled multilingual audio. It was fully trained in a supervised manner, with multiple tasks : 

- English transcription 
- Any-to-English speech translation
- Non-English transcription
- No speech prediction 

To each task corresponds a sequence of tokens that are given to the decoder as *context tokens*. The beginning of a transcription always starts with `<|startoftranscript|>` which is why the `decoder_start_token` is always set to `tokenizer.encode("<|startoftranscript|>")`. The following token should be the language token, which is automatically detected in the original code. Finally, the task is define using either `<|transcribe|>` or `<|translate|>`. In addition, a `<|notimestamps|>` token is added if the task does not include timestamp prediction.


# Usage

To transcribe or translate audio files, the model has to be used along a `WhisperProcessor`. The `WhisperProcessor.get_decoder_prompt_ids` function is used to get a list of `( idx, token )` tuples, which can either be set in the config, or directly passed to the generate function, as `forced_decoder_ids`. 


## Transcription 
In the following example, the english only model is used. We set the `decoder_input_ids` accordingly.


### English to english 
The "<|en|>" token is used to specify that the speech is in english and should be transcribed to english 

```python
>>> from transformers import WhisperProcessor, WhisperForConditionalGeneration
>>> from datasets import load_dataset
>>> import torch

>>> # load model and processor
>>> processor = WhisperProcessor.from_pretrained("openai/whisper-small.en")
>>> model = WhisperForConditionalGeneration.from_pretrained("openai/whisper-small.en")

>>> # load dummy dataset and read soundfiles
>>> ds = load_dataset("hf-internal-testing/librispeech_asr_dummy", "clean", split="validation")
>>> input_features = processor(ds[0]["audio"]["array"], return_tensors="pt").input_features 

>>> # Generate logits
>>> logits = model(input_features, decoder_input_ids = torch.tensor([[50258]])).logits 
>>> # take argmax and decode
>>> predicted_ids = torch.argmax(logits, dim=-1)
>>> transcription = processor.batch_decode(predicted_ids)
['<|startoftranscript|>']
```


## Evaluation

This code snippet shows how to evaluate **openai/whisper-small.en** on LibriSpeech's "clean" and "other" test data.
 
```python
>>> from datasets import load_dataset
>>> from transformers import WhisperForConditionalGeneration, WhisperProcessor
>>> import soundfile as sf
>>> import torch
>>> from evaluate import load


>>> librispeech_eval = load_dataset("librispeech_asr", "clean", split="test")

>>> model = WhisperForConditionalGeneration.from_pretrained("openai/whisper-small.en").to("cuda")
>>> processor = WhisperProcessor.from_pretrained("openai/whisper-small.en")

>>> def map_to_pred(batch):
>>>     input_features = processor(batch["audio"]["array"], return_tensors="pt").input_features

>>>     with torch.no_grad():
>>>         logits = model(input_features.to("cuda")).logits

>>>     predicted_ids = torch.argmax(logits, dim=-1)
>>>     transcription = processor.batch_decode(predicted_ids, normalize = True)
>>>     batch['text'] = processor.tokenizer._normalize(batch['text'])
>>>     batch["transcription"] = transcription
>>>     return batch

>>> result = librispeech_eval.map(map_to_pred, batched=True, batch_size=1, remove_columns=["speech"])

>>> wer = load("wer")
>>> print(wer.compute(predictions=ds["text"], references=ds["transcription"]))
0.07639504403417127
```


### Evaluated Use

The primary intended users of these models are AI researchers studying robustness, generalization, capabilities, biases, and constraints of the current model. However, Whisper is also potentially quite useful as an ASR solution for developers, especially for English speech recognition. We recognize that once models are released, it is impossible to restrict access to only “intended” uses or to draw reasonable guidelines around what is or is not research.

The models are primarily trained and evaluated on ASR and speech translation to English tasks. They show strong ASR results in ~10 languages. They may exhibit additional capabilities, particularly if fine-tuned on certain tasks like voice activity detection, speaker classification, or speaker diarization but have not been robustly evaluated in these areas. We strongly recommend that users perform robust evaluations of the models in a particular context and domain before deploying them.

In particular, we caution against using Whisper models to transcribe recordings of individuals taken without their consent or purporting to use these models for any kind of subjective classification. We recommend against use in high-risk domains like decision-making contexts, where flaws in accuracy can lead to pronounced flaws in outcomes. The models are intended to transcribe and translate speech, use of the model for classification is not only not evaluated but also not appropriate, particularly to infer human attributes.


## Training Data

The models are trained on 680,000 hours of audio and the corresponding transcripts collected from the internet. 65% of this data (or 438,000 hours) represents English-language audio and matched English transcripts, roughly 18% (or 126,000 hours) represents non-English audio and English transcripts, while the final 17% (or 117,000 hours) represents non-English audio and the corresponding transcript. This non-English data represents 98 different languages. 

As discussed in [the accompanying paper](https://cdn.openai.com/papers/whisper.pdf), we see that performance on transcription in a given language is directly correlated with the amount of training data we employ in that language.


## Performance and Limitations

Our studies show that, over many existing ASR systems, the models exhibit improved robustness to accents, background noise, technical language, as well as zero shot translation from multiple languages into English; and that accuracy on speech recognition and translation is near the state-of-the-art level. 

However, because the models are trained in a weakly supervised manner using large-scale noisy data, the predictions may include texts that are not actually spoken in the audio input (i.e. hallucination). We hypothesize that this happens because, given their general knowledge of language, the models combine trying to predict the next word in audio with trying to transcribe the audio itself.

Our models perform unevenly across languages, and we observe lower accuracy on low-resource and/or low-discoverability languages or languages where we have less training data. The models also exhibit disparate performance on different accents and dialects of particular languages, which may include higher word error rate across speakers of different genders, races, ages, or other demographic criteria. Our full evaluation results are presented in [the paper accompanying this release](https://cdn.openai.com/papers/whisper.pdf). 

In addition, the sequence-to-sequence architecture of the model makes it prone to generating repetitive texts, which can be mitigated to some degree by beam search and temperature scheduling but not perfectly. Further analysis on these limitations are provided in [the paper](https://cdn.openai.com/papers/whisper.pdf). It is likely that this behavior and hallucinations may be worse on lower-resource and/or lower-discoverability languages.


## Broader Implications

We anticipate that Whisper models’ transcription capabilities may be used for improving accessibility tools. While Whisper models cannot be used for real-time transcription out of the box – their speed and size suggest that others may be able to build applications on top of them that allow for near-real-time speech recognition and translation. The real value of beneficial applications built on top of Whisper models suggests that the disparate performance of these models may have real economic implications.

There are also potential dual use concerns that come with releasing Whisper. While we hope the technology will be used primarily for beneficial purposes, making ASR technology more accessible could enable more actors to build capable surveillance technologies or scale up existing surveillance efforts, as the speed and accuracy allow for affordable automatic transcription and translation of large volumes of audio communication. Moreover, these models may have some capabilities to recognize specific individuals out of the box, which in turn presents safety concerns related both to dual use and disparate performance. In practice, we expect that the cost of transcription is not the limiting factor of scaling up surveillance projects.


### BibTeX entry and citation info
*Since no official citation was provided, we use the following in the mean time*
```bibtex
@misc{radford2022whisper,
      title={Robust Speech Recognition via Large-Scale Weak Supervision.}, 
      author={Alec Radford, Jong Wook Kim, Tao Xu, Greg Brockman, Christine McLeavey, Ilya Sutskever},
      year={2022},
      url={https://cdn.openai.com/papers/whisper.pdf},
}
```
