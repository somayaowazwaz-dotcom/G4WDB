# G4War LLM Fine-tuning Project

This folder contains the setup for fine-tuning the **Gemma 2 2b** model (referred to as Gemma 4 e2b in the request).

## Setup Instructions

1. **Install Python**: Ensure you have Python 3.10+ installed.
2. **Install Dependencies**:
   ```bash
   pip install -r requirements.txt
   ```
3. **Hardware**: An NVIDIA GPU with at least 8GB VRAM is recommended for QLoRA fine-tuning.
4. **Hugging Face Login**: You need to accept the Gemma license on Hugging Face and log in:
   ```bash
   huggingface-cli login
   ```

## Dataset
Prepare your training data in `jsonl` format. Each line should be a JSON object:
```json
{"text": "Your training prompt and response here"}
```

## Running the Training
Update `train.py` with your dataset path and run:
```bash
python train.py
```

## Integrating with Flutter
Once fine-tuned, you can:
- Convert to **GGUF** for local inference on mobile/desktop using `llama.cpp`.
- Use **Mediapipe LLM Inference SDK** to run the model on Android/iOS.
- Host it on a server and call it via API.
