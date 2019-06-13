function roi = expandROI(roi, imsz, margin)

roi(1:2,:) = roi(1:2,:)-margin;
roi(3:4,:) = roi(3:4,:)+margin;

roi(1:2,:) = max(roi(1:2,:),1);
roi(3,:) = min(roi(3,:),imsz(2));
roi(4,:) = min(roi(4,:),imsz(1));