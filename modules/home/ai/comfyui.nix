{pkgs, ...}: let
  comfyuiRevision = "dec5d9450a5290bcf63430409ea41018e67f41c3";
  runtimeEnvironment = ''
    data_dir="''${XDG_DATA_HOME:-$HOME/.local/share}/ComfyUI"
    app_dir="$data_dir/app"
    venv_dir="$data_dir/.venv"
    constraints="$data_dir/constraints.txt"

    export CUDA_CACHE_PATH="$data_dir/.cache/cuda"
    export HF_HOME="$data_dir/.cache/huggingface"
    export TORCH_HOME="$data_dir/.cache/torch"
    export PIP_CONSTRAINT="$constraints"
    export UV_CONSTRAINT="$constraints"
    export LD_LIBRARY_PATH="/run/opengl-driver/lib:${pkgs.stdenv.cc.cc.lib}/lib:''${LD_LIBRARY_PATH:-}"
  '';
  comfyuiSetup = pkgs.writeShellApplication {
    name = "comfyui-setup";
    runtimeInputs = [pkgs.coreutils pkgs.git pkgs.uv];
    text = ''
            ${runtimeEnvironment}
            lock_file="$data_dir/requirements.lock"

            mkdir -p "$data_dir"/{custom_nodes,input,models,output,user} \
              "$CUDA_CACHE_PATH" "$HF_HOME" "$TORCH_HOME"

            if [[ -e "$app_dir" && ! -d "$app_dir/.git" ]]; then
              echo "Refusing to replace non-ComfyUI path: $app_dir" >&2
              echo "Move it aside, then run comfyui-setup again." >&2
              exit 1
            fi

            if [[ ! -d "$app_dir/.git" ]]; then
              git clone --depth 1 --branch v0.30.2 \
                https://github.com/Comfy-Org/ComfyUI.git "$app_dir"
            fi

            current_revision="$(git -C "$app_dir" rev-parse HEAD)"
            if [[ "$current_revision" != "${comfyuiRevision}" ]]; then
              echo "ComfyUI source is not the pinned v0.30.2 revision." >&2
              echo "Run comfyui-repair to restore the managed source and environment." >&2
              exit 1
            fi

            cat >"$constraints" <<'EOF'
      torch==2.5.1+cu121
      torchvision==0.20.1+cu121
      torchaudio==2.5.1+cu121
      comfy-kitchen==0.2.26
      EOF

            ${pkgs.uv}/bin/uv venv --clear --python ${pkgs.python312}/bin/python \
              --no-managed-python "$venv_dir"

            ${pkgs.uv}/bin/uv pip compile "$app_dir/requirements.txt" \
              --constraint "$constraints" \
              --python "$venv_dir/bin/python" \
              --python-platform x86_64-manylinux_2_28 \
              --torch-backend cu121 \
              --exclude-newer 2026-08-09T23:59:59Z \
              --generate-hashes \
              --output-file "$lock_file"

            ${pkgs.uv}/bin/uv pip sync "$lock_file" \
              --python "$venv_dir/bin/python" \
              --torch-backend cu121 \
              --require-hashes \
              --strict

            "$venv_dir/bin/python" - <<'PYTHON'
      import torch

      if not torch.cuda.is_available():
          raise SystemExit("PyTorch cannot access the NVIDIA GPU")

      capability = torch.cuda.get_device_capability()
      if capability != (6, 1):
          raise SystemExit(f"Expected a Pascal sm_61 GPU, found sm_{capability[0]}{capability[1]}")

      architectures = torch.cuda.get_arch_list()
      if "sm_61" not in architectures:
          raise SystemExit(f"Installed PyTorch wheel lacks sm_61 support: {architectures}")

      result = (torch.ones(1, device="cuda") * 2).item()
      torch.cuda.synchronize()
      if result != 2:
          raise SystemExit("CUDA tensor smoke test returned an unexpected result")

      print(f"CUDA smoke test passed: {torch.cuda.get_device_name(0)} ({torch.__version__})")
      PYTHON

            echo "ComfyUI v0.30.2 is ready. Start it with: comfyui"
    '';
  };
  comfyui = pkgs.writeShellApplication {
    name = "comfyui";
    runtimeInputs = [pkgs.coreutils pkgs.ffmpeg];
    text = ''
      ${runtimeEnvironment}

      if [[ ! -x "$venv_dir/bin/python" || ! -f "$app_dir/main.py" ]]; then
        echo "ComfyUI is not initialized. Run comfyui-setup first." >&2
        exit 1
      fi

      mkdir -p "$data_dir"/{custom_nodes,input,models,output,user} \
        "$CUDA_CACHE_PATH" "$HF_HOME" "$TORCH_HOME"

      exec "$venv_dir/bin/python" "$app_dir/main.py" \
        --base-directory "$data_dir" \
        --input-directory "$data_dir/input" \
        --output-directory "$data_dir/output" \
        --user-directory "$data_dir/user" \
        --lowvram \
        --use-pytorch-cross-attention \
        "$@"
    '';
  };
  comfyuiRepair = pkgs.writeShellApplication {
    name = "comfyui-repair";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      ${runtimeEnvironment}
      lock_file="$data_dir/requirements.lock"

      rm -rf -- "$app_dir" "$venv_dir"
      rm -f -- "$constraints" "$lock_file"
      exec ${comfyuiSetup}/bin/comfyui-setup
    '';
  };
in {
  home.packages = [comfyui comfyuiSetup comfyuiRepair];
}
