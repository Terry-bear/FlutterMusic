import 'dart:async';
import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:netease_cloud_music/application.dart';
import 'package:netease_cloud_music/model/song.dart';
import 'package:netease_cloud_music/model/user.dart';
import 'package:netease_cloud_music/utils/navigator_util.dart';
import 'package:netease_cloud_music/utils/net_utils.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netease_cloud_music/utils/utils.dart';

class PlaySongsModel with ChangeNotifier{
  AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer get audioPlayer => _audioPlayer;
  StreamController<String> _curPositionController = StreamController<String>.broadcast();

  List<Song> _songs = [];
  int curIndex = 0;
  Duration curSongDuration;
  AudioPlayerState _curState;

  List<Song> get allSongs => _songs;
  Song get curSong => _songs[curIndex];
  get curPositionStream => _curPositionController.stream;
  AudioPlayerState get curState => _curState;


  void init() {
    _audioPlayer.setReleaseMode(ReleaseMode.STOP);
    // 播放状态监听
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _curState = state;
      /// 先做顺序播放
      if(state == AudioPlayerState.COMPLETED){
        nextPlay();
      }
      // 其实也只有在播放状态更新时才需要通知。
      notifyListeners();
    });
    _audioPlayer.onDurationChanged.listen((d) {
      curSongDuration = d;
    });
    // 当前播放进度监听
    _audioPlayer.onAudioPositionChanged.listen((Duration p) {
      _curPositionController.sink.add('${p.inMilliseconds > curSongDuration.inMilliseconds ? curSongDuration.inMilliseconds : p.inMilliseconds}-${curSongDuration.inMilliseconds}');
    });
  }

  void playSong(Song song) {
    _songs.insert(curIndex, song);
    play();
  }

  void playSongs(List<Song> songs, {int index}) {
    this._songs = songs;
    if (index != null) curIndex = index;
    play();
  }

  void addSongs(List<Song> songs) {
    this._songs.addAll(songs);
  }

  /// 播放
  void play() {
    _audioPlayer.play(
        "https://music.163.com/song/media/outer/url?id=${this._songs[curIndex].id}.mp3");
  }

  /// 暂停、恢复
  void pausePlay() {
    if (_audioPlayer.state == AudioPlayerState.PAUSED) {
      resumePlay();
    } else {
      _audioPlayer.pause();
    }
  }

  /// 跳转到固定时间
  void seekPlay(int milliseconds){
    _audioPlayer.seek(Duration(milliseconds: milliseconds));
    resumePlay();
  }

  /// 恢复播放
  void resumePlay() {
    _audioPlayer.resume();
  }

  /// 下一首
  void nextPlay(){
    if(curIndex >= _songs.length){

    }else{
      curIndex++;
      play();
    }
  }

  void prePlay(){
    if(curIndex <= 0){

    }else{
      curIndex--;
      play();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _curPositionController.close();
    _audioPlayer.dispose();
  }


}
