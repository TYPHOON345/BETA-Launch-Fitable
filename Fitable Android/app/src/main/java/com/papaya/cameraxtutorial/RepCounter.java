package com.papaya.cameraxtutorial;

import static java.lang.Math.atan2;

import com.google.mlkit.vision.pose.Pose;
import com.google.mlkit.vision.pose.PoseLandmark;

import java.util.List;

public class RepCounter {

    int reps;
    String type;

    public int getReps() {
        return reps;
    }

    public void setReps(int reps) {
        this.reps = reps;
    }

    public RepCounter(String type) { this.type = type; }

    public String checkPose(List<PoseLandmark> landmarks, Float height) {
        if (landmarks != null) {
            PoseLandmark lh = null;
            PoseLandmark rh = null;
            PoseLandmark lk = null;
            PoseLandmark rk = null;
            PoseLandmark la = null;
            PoseLandmark ra = null;
            PoseLandmark ls = null;
            PoseLandmark rs = null;
            PoseLandmark lw = null;
            PoseLandmark rw = null;
            PoseLandmark le = null;
            PoseLandmark re = null;
            try {
                if (landmarks.get(PoseLandmark.LEFT_HIP).getInFrameLikelihood() > 0.5) {
                    lh = landmarks.get(PoseLandmark.LEFT_HIP);
                }
                if (landmarks.get(PoseLandmark.RIGHT_HIP).getInFrameLikelihood() > 0.5) {
                    rh = landmarks.get(PoseLandmark.RIGHT_HIP);
                }
                if (landmarks.get(PoseLandmark.LEFT_KNEE).getInFrameLikelihood() > 0.5) {
                    lk = landmarks.get(PoseLandmark.LEFT_KNEE);
                }
                if (landmarks.get(PoseLandmark.RIGHT_KNEE).getInFrameLikelihood() > 0.5) {
                    rk = landmarks.get(PoseLandmark.RIGHT_KNEE);
                }
                if (landmarks.get(PoseLandmark.LEFT_ANKLE).getInFrameLikelihood() > 0.5) {
                    la = landmarks.get(PoseLandmark.LEFT_ANKLE);
                }
                if (landmarks.get(PoseLandmark.RIGHT_ANKLE).getInFrameLikelihood() > 0.5) {
                    ra = landmarks.get(PoseLandmark.RIGHT_ANKLE);
                }
                if (landmarks.get(PoseLandmark.LEFT_SHOULDER).getInFrameLikelihood() > 0.5) {
                    ls = landmarks.get(PoseLandmark.LEFT_SHOULDER);
                }
                if (landmarks.get(PoseLandmark.RIGHT_SHOULDER).getInFrameLikelihood() > 0.5) {
                    rs = landmarks.get(PoseLandmark.RIGHT_SHOULDER);
                }
                if (landmarks.get(PoseLandmark.LEFT_WRIST).getInFrameLikelihood() > 0.5) {
                    lw = landmarks.get(PoseLandmark.LEFT_WRIST);
                }
                if (landmarks.get(PoseLandmark.RIGHT_WRIST).getInFrameLikelihood() > 0.5) {
                    rw = landmarks.get(PoseLandmark.RIGHT_WRIST);
                }
                if (landmarks.get(PoseLandmark.LEFT_ELBOW).getInFrameLikelihood() > 0.5) {
                    le = landmarks.get(PoseLandmark.LEFT_ELBOW);
                }
                if (landmarks.get(PoseLandmark.RIGHT_ELBOW).getInFrameLikelihood() > 0.5) {
                    re = landmarks.get(PoseLandmark.RIGHT_ELBOW);
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
            switch (type) {
                case "squats":
                    if (lh != null && rh != null && lk != null && rk != null) {
                        if (lh.getPosition().y <= (lk.getPosition().y + 50)) {
                            if (lh.getPosition().y >= lk.getPosition().y - 50) {
                                return "down";
                            } else {
                                return "hips too low";
                            }
                        } else {
                            return "up";
                        }
                    }
                    break;
                case "lunges":
                    if (lh != null && rh != null && lk != null && rk != null && la != null && ra != null) {
                        double leftLegAngle = getAngle(lh, lk, la);
                        double rightLegAngle = getAngle(rh, rk, ra);
                        if (leftLegAngle >= 80 && leftLegAngle <= 110) {
                            if (rightLegAngle >= 80 && rightLegAngle <= 110) {
                                return "down";
                            }
                        } else if (leftLegAngle > 110 && rightLegAngle > 110) {
                            return "up";
                        }
                    }
                    break;
                case "push-ups":
                    if (ls != null && rs != null && le != null && re != null && lw != null && rw != null) {
                        double leftArmAngle = getAngle(ls, le, lw);
                        double rightArmAngle = getAngle(rs, re, rw);
                        if (leftArmAngle >= 80 && leftArmAngle <= 110) {
                            if (rightArmAngle >= 80 && rightArmAngle <= 110) {
                                return "down";
                            }
                        } else if (leftArmAngle > 110 && rightArmAngle > 110) {
                            return "up";
                        }
                    }
                default:
                    return "error";

            }

        }
        return "error";

    }

    static double getAngle(PoseLandmark firstPoint, PoseLandmark midPoint, PoseLandmark lastPoint) {
        double result =
                Math.toDegrees(
                        atan2(lastPoint.getPosition().y - midPoint.getPosition().y,
                                lastPoint.getPosition().x - midPoint.getPosition().x)
                                - atan2(firstPoint.getPosition().y - midPoint.getPosition().y,
                                firstPoint.getPosition().x - midPoint.getPosition().x));
        result = Math.abs(result); // Angle should never be negative
        if (result > 180) {
            result = (360.0 - result); // Always get the acute representation of the angle
        }
        return result;
    }

}
