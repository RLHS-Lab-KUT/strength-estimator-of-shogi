#!/bin/bash
set -e

# ==========================================
# 1. ヘルプメッセージの定義
# ==========================================
usage()
{
    echo "Usage: $0 [OPTION]..."
    echo ""
    echo "Optional arguments:"
    echo "  -h, --help      Give this help list"
    echo "      --image     Select the image name of the container"
    echo "  -v, --volume    Bind mount a volume into the container"
    echo "      --name      Assign a name to the container"
    echo "  -d, --detach    Run container in background and print container ID"
    echo "  -H, --history   Record the container bash history"
    exit 1
}

# ==========================================
# 2. デフォルト変数の設定
# ==========================================
# 環境変数でIMAGE_NAMEが指定されていなければデフォルト値を使用
image_name="${IMAGE_NAME:-minizero-gpu-full}"
container_arguments=""
# ベースとなるワークスペースのマウント
container_volume="-v $(pwd):/workspace"
record_history=false

# ==========================================
# 3. コンテナツールの検出 (docker or podman)
# ==========================================
container_tool=$(basename $(which docker || which podman) 2>/dev/null)
if [[ ! $container_tool ]]; then
    echo "Neither podman nor docker is installed." >&2
    exit 1
fi

# ==========================================
# 4. 引数の解析
# ==========================================
while :; do
    case $1 in
        -h|--help) shift; usage
        ;;
        --image) shift; image_name=${1}
        ;;
        -v|--volume) shift; container_volume="${container_volume} -v ${1}"
        ;;
        --name) shift; container_arguments="${container_arguments} --name ${1}"
        ;;
        -d|--detach) container_arguments="${container_arguments} -d"
        ;;
        -H|--history) record_history=true
        ;;
        "") break
        ;;
        *) echo "Unknown argument: $1"; usage
        ;;
    esac
    shift
done

# ==========================================
# 5. コンテナ内のbash履歴の永続化設定 (-H)
# ==========================================
if [ "$record_history" = true ]; then
    history_dir=".container_root"
    # 履歴ディレクトリが存在しない場合は作成・初期化
    if [ ! -d ${history_dir} ]; then
        mkdir -p ${history_dir}
        # コンテナを一時的に起動して、/root の初期設定をローカルにコピー
        $container_tool run --rm -it -v "$(pwd)/${history_dir}:/container_root" ${image_name} /bin/bash -c "cp -r /root/. /container_root && touch /container_root/.bash_history && exit"
    fi
    # 履歴ディレクトリをマウント対象に追加（絶対パスで指定）
    container_volume="${container_volume} -v $(pwd)/${history_dir}:/root"
fi

# 余分な空白を削除
container_arguments=$(echo ${container_arguments} | xargs)

# ==========================================
# 6. コンテナの起動
# ==========================================
echo "Running MiniZero with GPU using ${container_tool} image: ${image_name}"

# 変数を展開して実行
$container_tool run ${container_arguments} \
  --gpus all \
  --cap-add=SYS_PTRACE \
  --security-opt seccomp=unconfined \
  --network=host \
  --ipc=host \
  --rm -it \
  -w /workspace \
  ${container_volume} \
  -e container=${container_tool} \
  ${image_name} \
  bash -lc 'git config --global --add safe.directory /workspace && exec bash'