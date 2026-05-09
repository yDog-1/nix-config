{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "update-apt" ''
      #!/bin/bash

      # APTパッケージの更新
      echo -e "\033[1;34m==> APTパッケージを更新しています...\033[0m"

      if sudo apt update; then
        echo -e "\033[1;32m✓ APTアップデート完了\033[0m"
      else
        echo -e "\033[1;31m✗ APTアップデート失敗\033[0m"
        exit 1
      fi

      if sudo apt upgrade -y; then
        echo -e "\033[1;32m✓ APTアップグレード完了\033[0m"
      else
        echo -e "\033[1;31m✗ APTアップグレード失敗\033[0m"
        exit 1
      fi

      if sudo apt autoremove -y; then
        echo -e "\033[1;32m✓ 不要なパッケージの削除完了\033[0m"
      else
        echo -e "\033[1;33m⚠ 不要なパッケージの削除スキップ\033[0m"
      fi

      if sudo apt autoclean; then
        echo -e "\033[1;32m✓ キャッシュのクリーンアップ完了\033[0m"
      else
        echo -e "\033[1;33m⚠ キャッシュのクリーンアップスキップ\033[0m"
      fi

      echo -e "\033[1;34m==> APTパッケージの更新が完了しました\033[0m"
    '')

    (pkgs.writeShellScriptBin "update-flake" ''
      #!/bin/bash

      # Home Manager flake.lockの更新
      echo -e "\033[1;34m==> Home Manager flake.lockを更新しています...\033[0m"

      ORIGINAL_DIR=$(pwd)
      CHEZMOI_HOME_MANAGER_DIR="$HOME/.local/share/chezmoi/dot_config/home-manager"

      if ! cd "$CHEZMOI_HOME_MANAGER_DIR" 2>/dev/null; then
        echo -e "\033[1;31m✗ Home Managerディレクトリが見つかりません: $CHEZMOI_HOME_MANAGER_DIR\033[0m"
        exit 1
      fi

      echo -e "\033[1;36m📁 作業ディレクトリ: $CHEZMOI_HOME_MANAGER_DIR\033[0m"

      if nix flake update; then
        echo -e "\033[1;32m✓ flake.lock更新完了\033[0m"
      else
        echo -e "\033[1;31m✗ flake.lock更新失敗\033[0m"
        cd "$ORIGINAL_DIR"
        exit 1
      fi

      echo -e "\033[1;36m🔄 Chezmoiで変更を適用中...\033[0m"
      if chezmoi apply; then
        echo -e "\033[1;32m✓ Chezmoi apply完了\033[0m"
      else
        echo -e "\033[1;31m✗ Chezmoi apply失敗\033[0m"
        cd "$ORIGINAL_DIR"
        exit 1
      fi

      echo -e "\033[1;36m🔄 Home Manager設定を適用中...\033[0m"
      if home-manager switch; then
        echo -e "\033[1;32m✓ Home Manager switch完了\033[0m"
      else
        echo -e "\033[1;31m✗ Home Manager switch失敗\033[0m"
        cd "$ORIGINAL_DIR"
        exit 1
      fi

      cd "$ORIGINAL_DIR"
      echo -e "\033[1;34m==> Home Managerの更新が完了しました\033[0m"
    '')

    (pkgs.writeShellScriptBin "update-system" ''
      #!/bin/bash

      apt_result=0
      flake_result=0

      # APTの更新
      update-apt
      apt_result=$?

      echo ""
      echo -e "\033[1;35m----------------------------------------\033[0m"
      echo ""

      # Home Managerの更新
      update-flake
      flake_result=$?

      echo ""
      echo -e "\033[1;35m========================================\033[0m"

      if [ $apt_result -eq 0 ] && [ $flake_result -eq 0 ]; then
        echo -e "\033[1;32m✓ すべての更新が正常に完了しました！\033[0m"
      elif [ $apt_result -ne 0 ] && [ $flake_result -ne 0 ]; then
        echo -e "\033[1;31m✗ APTとHome Managerの両方で更新に失敗しました\033[0m"
        exit 1
      elif [ $apt_result -ne 0 ]; then
        echo -e "\033[1;33m⚠ APTの更新に失敗しましたが、Home Managerは正常に更新されました\033[0m"
        exit 1
      else
        echo -e "\033[1;33m⚠ Home Managerの更新に失敗しましたが、APTは正常に更新されました\033[0m"
        exit 1
      fi

      echo -e "\033[1;35m========================================\033[0m"
    '')
  ];
}
