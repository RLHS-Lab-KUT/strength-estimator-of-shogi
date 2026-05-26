## 今までやってきたこと
* GPU使えるようにした
* ゲームが終了する条件を定義した(minizero/enviroment/shogi/shogi.cppのisTerminal())
* 

## 気になること
* strength/trainer/create_network.pyについて
  * .rank_networkからRankNetworkをインポートすると書いてあったが，これは必要か？
    * 快斗もBTでランク付けを行っているといっていた覚えがあるのでおそらく必要ないと思う
* 強さ推定器を動かすだけで修正が多すぎる
  * 私の修正が間違っている or 快斗が実際に使っていた設定が別である

## 現状
* `./scripts/train.sh shogi cfg/se_shogi.cfg`　このコマンドが実行できない
  * 以下実行したときのエラー文
  ```
    [Info] Loading data from: /workspace/training_shogi
    Traceback (most recent call last):
    File "/workspace/strength/trainer/train.py", line 392, in <module>
        data_loader = NpyDataLoader(
    File "/workspace/strength/trainer/train.py", line 48, in __init__
        self.load_all_data()
    File "/workspace/strength/trainer/train.py", line 61, in load_all_data
        all_subdirs = sorted([d for d in os.listdir(self.root_dir) if os.path.isdir(os.path.join(self.root_dir, d))])
    FileNotFoundError: [Errno 2] No such file or directory: '/workspace/training_shogi'
    CUDA_VISIBLE_DEVICES=0 PYTHONPATH=. python strength/trainer/train.py shogi shogi_bt_b32_r8_p6_20bx256-417c41-dirty shogi_bt_b32_r8_p6_20bx256-417c41-dirty/shogi_bt_b32_r8_p6_20bx256-417c41-dirty.cfg
    [Info] Loading data from: /workspace/training_shogi
    Traceback (most recent call last):
    File "/workspace/strength/trainer/train.py", line 392, in <module>
        data_loader = NpyDataLoader(
    File "/workspace/strength/trainer/train.py", line 48, in __init__
        self.load_all_data()
    File "/workspace/strength/trainer/train.py", line 61, in load_all_data
        all_subdirs = sorted([d for d in os.listdir(self.root_dir) if os.path.isdir(os.path.join(self.root_dir, d))])
    FileNotFoundError: [Errno 2] No such file or directory: '/workspace/training_shogi'
  ```
* 考えられる原因：棋譜を利用したデータの作成をDockerコンテナの中で行ったことによって，データの生成されるパスも変わっている
  * そのためトレーニングデータを参照するパスを指定いるファイルはすべて修正しないといけないかも