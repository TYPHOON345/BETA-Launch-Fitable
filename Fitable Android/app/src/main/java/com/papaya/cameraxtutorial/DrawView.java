package com.papaya.cameraxtutorial;

import android.content.Context;
import android.content.res.Resources;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.Point;
import android.graphics.PointF;
import android.util.Log;
import android.view.View;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;

import java.util.ArrayList;
import java.util.List;

public class DrawView extends View {
    Paint paint = new Paint();
    Paint whitePaint = new Paint();
    PointF scale = new PointF();
    float Scr_w;
    float Scr_h;
    List<PoseLandmark> landmarks;

    public DrawView(Context context) {
        super(context);
        paint.setColor(Color.RED);
        paint.setStrokeWidth(10f);
        whitePaint.setColor(Color.WHITE);
        whitePaint.setStrokeWidth(15f);



    }

    void DrawPose(List<PoseLandmark> landmarks, float width, float height, float viewX, float viewY) {
        if (landmarks != null) {
            this.landmarks = landmarks;
            Scr_w = width;
            Scr_h = height;
            scale.x = viewX;
            scale.y = viewY;
            invalidate();
        }
    }

    @Override
    protected void onDraw(Canvas canvas) {
        super.onDraw(canvas);

        if (landmarks != null && !landmarks.isEmpty()) {
            PointF ls = null;
            PointF rs = null;
            PointF le = null;
            PointF re = null;
            PointF lw = null;
            PointF rw = null;
            PointF lh = null;
            PointF rh = null;
            PointF lk = null;
            PointF rk = null;
            PointF la = null;
            PointF ra = null;
            if (landmarks.get(PoseLandmark.LEFT_SHOULDER).getInFrameLikelihood() > 0.5) {
                ls = landmarks.get(PoseLandmark.LEFT_SHOULDER).getPosition();
                ls.offset(scale.x, scale.y);
            }
            if (landmarks.get(PoseLandmark.RIGHT_SHOULDER).getInFrameLikelihood() > 0.5) {
                rs = landmarks.get(PoseLandmark.RIGHT_SHOULDER).getPosition();
                rs.offset(scale.x, scale.y);
            }
            if (landmarks.get(PoseLandmark.LEFT_ELBOW).getInFrameLikelihood() > 0.5) {
                le = landmarks.get(PoseLandmark.LEFT_ELBOW).getPosition();
                le.offset(scale.x, scale.y);
            }
            if (landmarks.get(PoseLandmark.RIGHT_ELBOW).getInFrameLikelihood() > 0.5) {
                re = landmarks.get(PoseLandmark.RIGHT_ELBOW).getPosition();
                re.offset(scale.x, scale.y);
            }
            if (landmarks.get(PoseLandmark.LEFT_WRIST).getInFrameLikelihood() > 0.5) {
                lw = landmarks.get(PoseLandmark.LEFT_WRIST).getPosition();
                lw.offset(scale.x, scale.y);
            }
            if (landmarks.get(PoseLandmark.RIGHT_WRIST).getInFrameLikelihood() > 0.5) {
                rw = landmarks.get(PoseLandmark.RIGHT_WRIST).getPosition();
                rw.offset(scale.x, scale.y);
            }
            if (landmarks.get(PoseLandmark.LEFT_HIP).getInFrameLikelihood() > 0.5) {
                lh = landmarks.get(PoseLandmark.LEFT_HIP).getPosition();
                lh.offset(scale.x, scale.y);
            }
            if (landmarks.get(PoseLandmark.RIGHT_HIP).getInFrameLikelihood() > 0.5) {
                rh = landmarks.get(PoseLandmark.RIGHT_HIP).getPosition();
                rh.offset(scale.x, scale.y);
            }
            if (landmarks.get(PoseLandmark.LEFT_KNEE).getInFrameLikelihood() > 0.5) {
                lk = landmarks.get(PoseLandmark.LEFT_KNEE).getPosition();
                lk.offset(scale.x, scale.y);
            }
            if (landmarks.get(PoseLandmark.RIGHT_KNEE).getInFrameLikelihood() > 0.5) {
                rk = landmarks.get(PoseLandmark.RIGHT_KNEE).getPosition();
                rk.offset(scale.x, scale.y);
            }
            if (landmarks.get(PoseLandmark.LEFT_ANKLE).getInFrameLikelihood() > 0.5) {
                la = landmarks.get(PoseLandmark.LEFT_ANKLE).getPosition();
                la.offset(scale.x, scale.y);
            }
            if (landmarks.get(PoseLandmark.RIGHT_ANKLE).getInFrameLikelihood() > 0.5) {
                ra = landmarks.get(PoseLandmark.RIGHT_ANKLE).getPosition();
                ra.offset(scale.x, scale.y);
            }

            PointF[] bodyPoints = {ls, rs, le, re, lw, rw, lh, rh, lk, rk, la, ra};
            PointF[][] lines = {{ls, le}, {rs, re}, {le, lw}, {re, rw}, {ls, rs}, {ls, lh}, {rs, rh}, {lh, rh}, {lh, lk}, {rh, rk}, {lk, la}, {rk, ra}};
            for (int i = 0; i < lines.length; i++) {
                try {
                    canvas.drawLine(lines[i][0].x, lines[i][0].y, lines[i][1].x, lines[i][1].y, paint);
                } catch (Exception e) {
                    Log.d("smth", String.valueOf(e));
                }
            }

            for (int i = 0; i < bodyPoints.length; i++) {
                try {
                    canvas.drawPoint(bodyPoints[i].x, bodyPoints[i].y, whitePaint);
                } catch (Exception e) {
                    Log.d("smth", String.valueOf(e));
                }
            }




        }
    }
}
