import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:netease_cloud_music/provider/play_songs_model.dart';
import 'package:netease_cloud_music/widgets/common_text_style.dart';

class SongProgressWidget extends StatelessWidget {

  final PlaySongsModel model;

  SongProgressWidget(this.model);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      stream: model.curPositionStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var totalTime =
          snapshot.data.substring(snapshot.data.indexOf('-') + 1);
          var curTime =
          snapshot.data.substring(0, snapshot.data.indexOf('-'));
          return Container(
            height: ScreenUtil().setWidth(120),
            child: Row(
              children: <Widget>[
                Text(
                  DateUtil.formatDateMs(int.parse(curTime), format: "mm:ss"),
                  style: smallWhiteTextStyle,
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: ScreenUtil().setWidth(2),
                      thumbShape: RoundSliderThumbShape(
                        enabledThumbRadius: ScreenUtil().setWidth(10),
                      ),
                    ),
                    child: Slider(
                      value: double.parse(curTime),
                      onChanged: (data) {},
                      onChangeStart: (data){
                        model.pausePlay();
                      },
                      onChangeEnd: (data){
                        model.seekPlay(data.toInt());
                      },
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                      min: 0,
                      max: double.parse(totalTime),
                    ),
                  ),
                ),
                Text(
                  DateUtil.formatDateMs(int.parse(totalTime), format: "mm:ss"),
                  style: smallWhite30TextStyle,
                ),
              ],
            ),
          );
        } else {
          return Container(
            height: ScreenUtil().setWidth(120),
          );
        }
      },
    );
  }
}
