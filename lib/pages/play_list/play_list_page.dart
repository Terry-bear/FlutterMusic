import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netease_cloud_music/model/music.dart';
import 'package:netease_cloud_music/model/play_list.dart';
import 'package:netease_cloud_music/model/recommend.dart';
import 'package:netease_cloud_music/pages/play_list/play_list_desc_dialog.dart';
import 'package:netease_cloud_music/utils/net_utils.dart';
import 'package:netease_cloud_music/widgets/common_text_style.dart';
import 'package:netease_cloud_music/widgets/h_empty_view.dart';
import 'package:netease_cloud_music/widgets/v_empty_view.dart';
import 'package:netease_cloud_music/widgets/widget_footer_tab.dart';
import 'package:netease_cloud_music/widgets/widget_music_list_item.dart';
import 'package:netease_cloud_music/widgets/widget_ovar_img.dart';
import 'package:netease_cloud_music/widgets/widget_play_list_app_bar.dart';
import 'package:netease_cloud_music/widgets/widget_play_list_cover.dart';
import 'package:netease_cloud_music/widgets/widget_sliver_future_builder.dart';

class PlayListPage extends StatefulWidget {
  final Recommend data;

  PlayListPage(this.data);

  @override
  _PlayListPageState createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  double _expandedHeight = ScreenUtil().setWidth(610);
  Playlist _data;

  /// 构建歌单简介
  Widget buildDescription() {
    return GestureDetector(
      onTap: () {
        showGeneralDialog(
          context: context,
          pageBuilder: (BuildContext buildContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return PlayListDescDialog(_data);
          },
          barrierDismissible: true,
          barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
          transitionDuration: const Duration(milliseconds: 150),
          transitionBuilder: _buildMaterialDialogTransitions,
        );
      },
      child: Row(
        children: <Widget>[
          Expanded(
            child: _data == null
                ? Container()
                : Text(
                    _data.description,
                    style: smallWhite70TextStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
          _data == null
              ? Container()
              : Icon(
                  Icons.keyboard_arrow_right,
                  color: Colors.white70,
                ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          PlayListAppBarWidget(
            sigma: 20,
            content: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  left: ScreenUtil().setWidth(35),
                  right: ScreenUtil().setWidth(35),
                  top: ScreenUtil().setWidth(120),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        PlayListCoverWidget(
                          widget.data.picUrl,
                          width: 250,
                          playCount: widget.data.playcount,
                        ),
                        HEmptyView(20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(
                                widget.data.name,
                                softWrap: true,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: mWhiteBoldTextStyle,
                              ),
                              VEmptyView(10),
                              Row(
                                children: <Widget>[
                                  _data == null
                                      ? Container()
                                      : OverImgWidget(
                                          _data.creator.avatarUrl, 50),
                                  HEmptyView(5),
                                  Expanded(
                                    child: _data == null
                                        ? Container()
                                        : Text(
                                            _data.creator.nickname,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: commonWhite70TextStyle,
                                          ),
                                  ),
                                  _data == null
                                      ? Container()
                                      : Icon(
                                          Icons.keyboard_arrow_right,
                                          color: Colors.white70,
                                        ),
                                ],
                              ),
                              VEmptyView(10),
                              buildDescription(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    VEmptyView(10),
                    Row(
                      children: <Widget>[
                        FooterTabWidget(
                            'images/icon_comment.png',
                            '${_data == null ? "评论" : _data.commentCount}',
                            () {}),
                        FooterTabWidget(
                            'images/icon_share.png',
                            '${_data == null ? "分享" : _data.shareCount}',
                            () {}),
                        FooterTabWidget(
                            'images/icon_download.png', '下载', () {}),
                        Expanded(
                          child: GestureDetector(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: ScreenUtil().setWidth(70),
                                  height: ScreenUtil().setWidth(70),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Image.asset(
                                      'images/icon_multi_select.png',
                                      width: ScreenUtil().setWidth(40),
                                      height: ScreenUtil().setWidth(40),
                                      fit: BoxFit.fitWidth,
                                    ),
                                  ),
                                ),
                                Text(
                                  '多选',
                                  style: common14White70TextStyle,
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            expandedHeight: _expandedHeight,
            backgroundImg: widget.data.picUrl,
            title: widget.data.name,
            count: _data == null ? null : _data.trackCount,
          ),
          CustomSliverFutureBuilder<PlayListData>(
            futureFunc: NetUtils.getPlayListData,
            params: {'id': widget.data.id},
            builder: (context, data) {
              setData(data.playlist);
              return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                var d = data.playlist.tracks[index];
                return WidgetMusicListItem(MusicData(
                  mvid: d.mv,
                  index: index + 1,
                  songName: d.name,
                  artists:
                      '${d.ar.map((a) => a.name).toList().join('/')} - ${d.al.name}',
                ));
              }, childCount: data.playlist.trackIds.length));
            },
          ),
        ],
      ),
    );
  }

  void setData(Playlist data) {
    Future.delayed(Duration(milliseconds: 50), () {
      if (mounted) {
        setState(() {
          _data = data;
        });
      }
    });
  }

  Widget _buildMaterialDialogTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      ),
      child: child,
    );
  }
}
