import cv2
from recolor import Core

# import
cap = cv2.VideoCapture(0)

while(1):
    # get a frame
    ret, frame = cap.read()
    rgb_frame=cv2.cvtColor(frame,cv2.COLOR_BGR2RGB)/255
    correctFrame = Core.video_correct(input_np=rgb_frame,
                                        return_type='np',
                                        protanopia_degree=0.5,
                                        deuteranopia_degree=0.0)
    # show a frame
    cv2.imshow("capture", correctFrame)
    if cv2.waitKey(1) & 0xFF == ord('q'):
        break
cap.release()
cv2.destroyAllWindows()
