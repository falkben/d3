function fill_stationary_points
global D3_GLOBAL

for n = 1:length(D3_GLOBAL.spatial_model.point)
  if D3_GLOBAL.spatial_model.point(n).stationary == 1
    for c = 1:2
      for xy = 1:2
        D3_GLOBAL.rawdata.point(n).cam(c).coordinate(1:D3_GLOBAL.max_frames,xy)...
          = D3_GLOBAL.rawdata.point(n).cam(c).coordinate(1,xy);
      end
    end
  end
end