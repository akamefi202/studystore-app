//  0  =< x <= 1, 0 <= y <= 1, ratio = image_height / image_width

const seatPositions = [
  // 1
  // x: 197, y: 392, width: 82, height: 48, image_width: 450, image_height: 800
  {'x': 0.438, 'y': 0.490, 'width': 0.103, 'height': 0.060, 'ratio': 1.778},
  // 2
  // x: 197, y: 470, width: 82, height: 48, image_width: 450, image_height: 800
  {'x': 0.438, 'y': 0.588, 'width': 0.103, 'height': 0.060, 'ratio': 1.778},
  // 3
  // x: 197, y: 550, width: 82, height: 48, image_width: 450, image_height: 800
  {'x': 0.438, 'y': 0.688, 'width': 0.103, 'height': 0.060, 'ratio': 1.778},
  // 4
  // x: 78, y: 550, width: 82, height: 48, image_width: 450, image_height: 800
  {'x': 0.173, 'y': 0.688, 'width': 0.103, 'height': 0.060, 'ratio': 1.778},
  // 5
  // x: 78, y: 470, width: 82, height: 48, image_width: 450, image_height: 800
  {'x': 0.173, 'y': 0.588, 'width': 0.103, 'height': 0.060, 'ratio': 1.778},
  // 6
  // x: 78, y: 392, width: 82, height: 48, image_width: 450, image_height: 800
  {'x': 0.173, 'y': 0.490, 'width': 0.103, 'height': 0.060, 'ratio': 1.778},
  // 7
  // x: 432, y: 1676, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.400, 'y': 0.873, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 8
  // x: 349, y: 1676, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.323, 'y': 0.873, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 9
  // x: 267, y: 1676, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.247, 'y': 0.873, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 10
  // x: 184, y: 1676, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.170, 'y': 0.873, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 11
  // x: 184, y: 1482, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.170, 'y': 0.772, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 12
  // x: 267, y: 1482, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.247, 'y': 0.772, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 13
  // x: 349, y: 1482, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.323, 'y': 0.772, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 14
  // x: 432, y: 1482, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.400, 'y': 0.772, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 15
  // x: 432, y: 1405, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.400, 'y': 0.732, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 16
  // x: 349, y: 1405, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.323, 'y': 0.732, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 17
  // x: 267, y: 1405, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.247, 'y': 0.732, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 18
  // x: 184, y: 1405, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.170, 'y': 0.732, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 19
  // x: 184, y: 1215, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.170, 'y': 0.633, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 20
  // x: 267, y: 1215, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.247, 'y': 0.633, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 21
  // x: 349, y: 1215, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.323, 'y': 0.633, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 22
  // x: 432, y: 1215, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.400, 'y': 0.633, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 23
  // x: 432, y: 1006, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.400, 'y': 0.524, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 24
  // x: 349, y: 1006, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.323, 'y': 0.524, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 25
  // x: 267, y: 1006, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.247, 'y': 0.524, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 26
  // x: 184, y: 1006, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.170, 'y': 0.524, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 27
  // x: 184, y: 925, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.170, 'y': 0.482, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 28
  // x: 267, y: 925, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.247, 'y': 0.482, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 29
  // x: 349, y: 925, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.323, 'y': 0.482, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 30
  // x: 432, y: 925, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.400, 'y': 0.482, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 31
  // x: 432, y: 720, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.400, 'y': 0.375, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 32
  // x: 349, y: 720, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.323, 'y': 0.375, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 33
  // x: 267, y: 720, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.247, 'y': 0.375, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 34
  // x: 184, y: 720, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.170, 'y': 0.375, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 35
  // x: 184, y: 648, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.170, 'y': 0.338, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 36
  // x: 267, y: 648, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.247, 'y': 0.338, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 37
  // x: 349, y: 648, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.323, 'y': 0.338, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 38
  // x: 432, y: 648, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.400, 'y': 0.338, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 39
  // x: 432, y: 443, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.400, 'y': 0.231, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 40
  // x: 349, y: 443, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.323, 'y': 0.231, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 41
  // x: 267, y: 443, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.247, 'y': 0.231, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 42
  // x: 184, y: 443, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.170, 'y': 0.231, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 43
  // x: 209, y: 242, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.194, 'y': 0.126, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 44
  // x: 292, y: 242, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.270, 'y': 0.126, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 45
  // x: 374, y: 242, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.346, 'y': 0.126, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 46
  // x: 457, y: 242, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.423, 'y': 0.126, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 47
  // x: 539, y: 242, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.499, 'y': 0.126, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 48
  // x: 622, y: 242, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.576, 'y': 0.126, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 49
  // x: 704, y: 242, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.652, 'y': 0.126, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 50
  // x: 787, y: 242, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.729, 'y': 0.126, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 51
  // x: 869, y: 242, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.805, 'y': 0.126, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 52
  // x: 933, y: 412, image_width: 1080, image_height: 1920
  {'x': 0.864, 'y': 0.215, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 53
  // x: 933, y: 494, image_width: 1080, image_height: 1920
  {'x': 0.864, 'y': 0.257, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 54
  // x: 933, y: 577, image_width: 1080, image_height: 1920
  {'x': 0.864, 'y': 0.301, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 55
  // x: 933, y: 659, image_width: 1080, image_height: 1920
  {'x': 0.864, 'y': 0.343, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 56
  // x: 933, y: 741, image_width: 1080, image_height: 1920
  {'x': 0.864, 'y': 0.386, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 57
  // x: 933, y: 824, image_width: 1080, image_height: 1920
  {'x': 0.864, 'y': 0.429, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 58
  // x: 731, y: 687, image_width: 1080, image_height: 1920
  {'x': 0.677, 'y': 0.358, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 59
  // x: 731, y: 606, image_width: 1080, image_height: 1920
  {'x': 0.677, 'y': 0.316, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 60
  // x: 731, y: 524, image_width: 1080, image_height: 1920
  {'x': 0.677, 'y': 0.273, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 61
  // x: 661, y: 524, image_width: 1080, image_height: 1920
  {'x': 0.612, 'y': 0.273, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 62
  // x: 661, y: 606, image_width: 1080, image_height: 1920
  {'x': 0.612, 'y': 0.316, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 63
  // x: 661, y: 687, image_width: 1080, image_height: 1920
  {'x': 0.612, 'y': 0.358, 'width': 0.065, 'height': 0.071, 'ratio': 1.778},
  // 64
  // x: 908, y: 992, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.840, 'y': 0.517, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 65
  // x: 825, y: 992, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.764, 'y': 0.517, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 66
  // x: 743, y: 992, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.688, 'y': 0.517, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 67
  // x: 743, y: 1185, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.688, 'y': 0.617, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 68
  // x: 825, y: 1185, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.764, 'y': 0.617, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
  // 69
  // x: 908, y: 1185, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.840, 'y': 0.617, 'width': 0.071, 'height': 0.063, 'ratio': 1.778},
];

const meetingRoomPositions = [
  // 1
  // x: 263, y: 770, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.244, 'y': 0.401, 'width': 0.192, 'height': 0.110, 'ratio': 1.778},
  // 2
  // x: 309, y: 1505, width: 56, height: 50, image_width: 1080, image_height: 1920
  {'x': 0.286, 'y': 0.784, 'width': 0.106, 'height': 0.301, 'ratio': 1.778},
];
