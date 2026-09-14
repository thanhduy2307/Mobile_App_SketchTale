import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class AppState extends ChangeNotifier {
  // Kid Profile Data
  String kidName = 'Bé Bo';
  int stars = 120;
  int streakDays = 3;
  int screenTimeMinutesAllowed = 45;
  int screenTimeUsedToday = 20;

  // Selected Story for Reading & Role assignment
  late Story currentStory;

  // Character Roles Assignment
  KidCharacter? heroCharacter;
  KidCharacter? companionCharacter;

  // List of kid's characters
  List<KidCharacter> characters = [];

  // List of all interactive stories
  List<Story> stories = [];

  // Filter for Library
  String selectedCategory = 'Tất cả';

  // Drawing Canvas State
  List<List<DrawingPoint>> strokeLines = [];
  Color currentBrushColor = AppColors.primaryContainer;
  double currentBrushSize = 8.0;
  bool isEraserMode = false;
  bool isCameraScannerMode = false;

  AppState() {
    _initializeInitialData();
  }

  void _initializeInitialData() {
    // Initial Pre-loaded Characters from Stitch AI mockups
    characters = [
      KidCharacter(
        id: 'char_1',
        name: 'Khủng Long Cam Bibo',
        title: 'Dũng sĩ tí hon vui vẻ',
        description: 'Bạn khủng long màu cam vui tính, luôn yêu thích việc thám hiểm và bảo vệ muôn loài.',
        drawingUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBs1j3zRcevls4hct7nBLNl-MkQnsK7toexPnjvrTD6o6grUe5LRVFr48TmDhOkJRfp5Y4vH9CBxVELjUEZjdk4_PwjzWXqSy_jPmk5x8lm-6H8YcUa_VmryBJa7ZbuS-RvYRs3HFFNUR0ER83b8VqqyfVywEVMGXGWhsd64VL4q00kJkrvW8cj30w-LJRCoY6LJxTsWfvShrWvjBoiwMYTe8nRFsuOj1pcrEeyCZPjTibGAPFHUwpG',
        avatar3dUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB9oZOVJC6DPIwJTkxGEEUWEu_mwzFvpXcDAd0AMoIg2bEe6d38DGSi_LAkDXRSiQa9IHuMk81jz4YgPMZwmgDGA78k8oqZ0ak3oxwvFl5ET3TglIxmkPgMUA-OsRmKcKu0WUba-cz2l-jkWxXJPKm49h80eW6LuULTqTUzLPFilNcfiD0GZJ9pc0DOYX2caBfUhBhky_qljX1zdzP7fB6t6YzVfdfdVj6bTTW7PlhD4Tb_ZknjEbLK',
        isParentApproved: true,
        voicePhrase: 'Chào cậu chủ nhỏ! Tớ đã sẵn sàng cùng cậu thám hiểm Rừng Phép Thuật rồi nè, Roar! 🦖',
        themeColor: AppColors.secondaryContainer,
        assignedRole: 'Dũng Sĩ Rừng Xanh 🦁',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      KidCharacter(
        id: 'char_2',
        name: 'Gấu Bông Siêu Nhân',
        title: 'Người hùng ấm áp',
        description: 'Chú gấu bông với chiếc áo choàng đỏ rực rỡ, luôn ôm chặt và sưởi ấm mọi người.',
        drawingUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB8Yw2nDsZD2i7T8eDXnOZ0Jpayw3A4CTRzVoAiufYwRxqIYNJP9_gXYH4NRDHuu5tULxxmZNjY-x-S1qz3Y-BDeRExrn5ojsvHb_WHfaV89b51FbfSTbFhEF5ZaEPPccyVCZOHm3UvcMkmrKpiS_A3ZVfS-a1KPikgFpkec5SeMjMfTTsRLP9p75vzBF8-cO28yiRJOZuhlOvxYR0Gu18vANXXpejgrEXHWZHxhyyPlCWUOPFebNQa',
        avatar3dUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB8Yw2nDsZD2i7T8eDXnOZ0Jpayw3A4CTRzVoAiufYwRxqIYNJP9_gXYH4NRDHuu5tULxxmZNjY-x-S1qz3Y-BDeRExrn5ojsvHb_WHfaV89b51FbfSTbFhEF5ZaEPPccyVCZOHm3UvcMkmrKpiS_A3ZVfS-a1KPikgFpkec5SeMjMfTTsRLP9p75vzBF8-cO28yiRJOZuhlOvxYR0Gu18vANXXpejgrEXHWZHxhyyPlCWUOPFebNQa',
        isParentApproved: true,
        voicePhrase: 'Gấu bông siêu nhân xuất hiện! Không sợ bóng tối nữa nhé, ôm tớ nào! 🧸',
        themeColor: AppColors.primaryContainer,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      KidCharacter(
        id: 'char_3',
        name: 'Mèo Bay Cầu Vồng',
        title: 'Bay vút đến xứ kẹo',
        description: 'Chú mèo lông trắng muốt với đôi cánh cầu vồng lấp lánh như kẹo ngọt.',
        drawingUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB4lFURVw3MFnAM_jkixmd-sSZbTj5vUAqMNNPMnvZOFqEeqvl9Heth4xoy-I8oOW0kJV6PL4BqM2aaoWuCvUbFWt1dDOWppC1n67h8x1Q8FNb9tD53OSCdNNsJELFEma3EW-suvrutg97hW4rILF40rNEDKKvOd313Oz5ueoNeK2c5augMITKuPvvZJFAm9V7pEDnSrlwndQBJX8im3wPxVyDCuLaNBgYgOxEOP1rBRZlpb6RvDMBl',
        avatar3dUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuB4lFURVw3MFnAM_jkixmd-sSZbTj5vUAqMNNPMnvZOFqEeqvl9Heth4xoy-I8oOW0kJV6PL4BqM2aaoWuCvUbFWt1dDOWppC1n67h8x1Q8FNb9tD53OSCdNNsJELFEma3EW-suvrutg97hW4rILF40rNEDKKvOd313Oz5ueoNeK2c5augMITKuPvvZJFAm9V7pEDnSrlwndQBJX8im3wPxVyDCuLaNBgYgOxEOP1rBRZlpb6RvDMBl',
        isParentApproved: false, // Pending approval
        voicePhrase: 'Meo meo! Tớ sẽ chở bé bay qua đám mây cầu vồng ngọt ngào nhé! 🐱🌈',
        themeColor: AppColors.accentLilac,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      KidCharacter(
        id: 'char_4',
        name: 'Cá Heo Biết Hát',
        title: 'Giọng ca đại dương',
        description: 'Chú cá heo xanh đeo tai nghe phát sáng, bơi lội và cất tiếng hát du dương.',
        drawingUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCYeAtr_SNO28hkvZTX0egWOyh6LuQpnN9cNb6rZWBBZ8SmCLyl5k47SiuG9JubtTLk5eT4ucXfX71qGcDYnPaQFpzMfPGoF5Q8mkAhu_WTihgF5FtZj9UD4kXsGSDQ6ISneAh_rZtRBzUSsu4fvwIXI_xa8X1YZBJ-4rTr0QvwP7yFoK9y0UB4llWXsOswBd-nal_yixi57EOOjalqKuxxjveMAXAx5TIOEsferJq4NWKecEhSHR-z',
        avatar3dUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCYeAtr_SNO28hkvZTX0egWOyh6LuQpnN9cNb6rZWBBZ8SmCLyl5k47SiuG9JubtTLk5eT4ucXfX71qGcDYnPaQFpzMfPGoF5Q8mkAhu_WTihgF5FtZj9UD4kXsGSDQ6ISneAh_rZtRBzUSsu4fvwIXI_xa8X1YZBJ-4rTr0QvwP7yFoK9y0UB4llWXsOswBd-nal_yixi57EOOjalqKuxxjveMAXAx5TIOEsferJq4NWKecEhSHR-z',
        isParentApproved: true,
        voicePhrase: 'La la la! Đại dương xanh mát vẫy gọi chúng mình cùng lướt sóng nào! 🐬🎵',
        themeColor: AppColors.tertiaryContainer,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    heroCharacter = characters[0];
    companionCharacter = characters[1];

    // Initial Stories
    stories = [
      Story(
        id: 'story_1',
        title: 'Bí Mật Rừng Nấm Thần Tiên',
        subtitle: 'Hành trình tìm quả táo vàng cứu muôn thú',
        coverUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAs_lv4z1qjmjlVnYB1Fx7ZEM5eX-s2aK869C8tcCpLbLJ9Ahr2gQ26yT271kAkfCJNYxxaBd27nytcZomORvEw6ltfGqqkFqIzTRyAc6aEBg-QQr6XfjO_rp6gNLqlYRkVnVu04yBN_oQ9H5I6_BG6pRiH1A3bH9qX34ouH3lyXCvHT3VE92dxg6UFolkNh8YmyaH_UUQf607HiWOd6apZj7WfV9TO0OuqpV6LKqQPyFDSdEnkD-2p',
        ageRange: '4 - 6 tuổi',
        category: 'Phiêu lưu',
        totalPages: 6,
        currentPage: 3,
        isCompleted: false,
        heroRoleTitle: 'Dũng Sĩ Rừng Xanh 🦁',
        companionRoleTitle: 'Thỏ Trắng Tinh Nghịch 🐰',
        pages: [
          const StoryPage(
            pageNumber: 1,
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAs_lv4z1qjmjlVnYB1Fx7ZEM5eX-s2aK869C8tcCpLbLJ9Ahr2gQ26yT271kAkfCJNYxxaBd27nytcZomORvEw6ltfGqqkFqIzTRyAc6aEBg-QQr6XfjO_rp6gNLqlYRkVnVu04yBN_oQ9H5I6_BG6pRiH1A3bH9qX34ouH3lyXCvHT3VE92dxg6UFolkNh8YmyaH_UUQf607HiWOd6apZj7WfV9TO0OuqpV6LKqQPyFDSdEnkD-2p',
            textContent: 'Ở một thung lũng xa xôi, những cây nấm thần tiên bỗng tỏa ra ánh sáng lấp lánh lạ kỳ trong sớm mai...',
          ),
          const StoryPage(
            pageNumber: 2,
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDf3Tk84WeWhgHX1pHSLMVsCAYb0wd4mYJF9e2THfQ_dMG44GVPf_D1Ind_p0ga5qZasYVH8nteSidQzGhHhfjwLSzNk-TAE27fGMe37-nzioStOi4WCF2clzkBFuYk0gog3aGd4nbB4Lb2WmLJNf22qZC_vw7dyx6P1tnNKVM-GPGm-f_otlfyujoJ7Y1H1-hW5AtZ-V8cj2D3uNNvkyBVxtsn2kG7FdHnjzq34VW-bmLAYDgfvaTn',
            textContent: 'Các loài thú nhỏ lo lắng vì cây cổ thụ đang héo úa. Chỉ có quả táo vàng phép thuật mới có thể chữa lành cho rừng xanh.',
          ),
          const StoryPage(
            pageNumber: 3,
            imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDToeEuGuXilp1aivNp1QhxJaBtvo2vY8Btd5vUkbOtYYf7ZBbToHqugpgE4UUIeGoxLaXec-n4ezNZOin3NEtSdH6DuysMgLpP140eKQgcnrwjpLDOXYj_hNhJjt8zfUlfDFyEnm63vK3chXxNWHBq3dFZWpX2gNfkUy2ErCpL_UMRk4Ar6PLwzgC_phiBDOQJcABD3qoTVFrzZ1p0lRXMxj5A6HC-Mvn2CD_bEIwMisesLgor1Fhb',
            textContent: 'Ngày xửa ngày xưa, bạn Khủng Long Cam rất dũng cảm bước vào khu rừng thần tiên để tìm kiếm quả táo vàng giúp muôn thú khoẻ mạnh...',
            vocab: VocabItem(
              word: 'Dũng Cảm',
              phonetic: '/dǔŋ ka᷉ːm/',
              definition: 'Là khi em không ngại thử thách mới, dám bảo vệ bạn bè khi gặp khó khăn!',
            ),
          ),
        ],
        quiz: const QuizQuestion(
          questionText: 'Trong câu chuyện, bạn Khủng Long Cam đã tìm thấy quả gì trong khu rừng thần tiên?',
          visualClueUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBPyd-YDByYm83ZYDFRN-xLLU89Uu6wmyADyRyc4fGoRJERXNE2swCRX0It7wNiJUtxp414ObYVTUvwiOFZCtmWd-QDHPNrDDjHFOQBkSMLIqz6h-wtTGPPJDoVxjCVFmSCu11pk8WDx0iRBLxlaR-X2USS1_uJCPNRWtR0DvgVM6JWsMQ0Vc6TXQUOtRUcFTRUjoJR6-TjQ1FKeG2Sn7C1D7jsWFEQZlidk39j5R62ePdo6zSwp2eL',
          options: ['Quả Táo Vàng ✨', 'Quả Dưa Hấu Khổng Lồ', 'Quả Chuối Xanh'],
          optionEmojis: ['🍎', '🍉', '🍌'],
          correctIndex: 0,
          celebrationTitle: 'Chính xác rồi!',
          celebrationMessage: 'Bé thông minh lắm, bạn Khủng Long Cam rất vui vì được chia sẻ táo vàng!',
          rewardStars: 5,
        ),
      ),
      const Story(
        id: 'story_2',
        title: 'Chú Chó Cứu Hỏa',
        subtitle: 'Tranh vẽ bởi: Bé Bo',
        coverUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDUnv_tax-sWDIH-HcFWNdoCvgDthGQqiO8QeAOEJWZjUZ_DMAf9NNU_otzEaE3cL7vyc8BIMjqUpV8EU7xlzYL-QTqdkUN6zggac0rhZg76J8esoO9xcstJMlf4ZHDtEDzBw47zuI0RpB9uk_Qg7tXnYH_Dp5rZ1I4Y9nOuhOtYYtJ2b0fX3QMwUkbD3YpFSvmGpCwcaWX4woNntNIbiGCySkl7UnkLdmmk0Nx_owAyXiAvkkA2tKb',
        ageRange: '3 - 5 tuổi',
        category: 'Động vật 🦁',
        totalPages: 5,
        currentPage: 5,
        isCompleted: true,
        pages: [],
        quiz: QuizQuestion(
          questionText: 'Chú chó cứu hỏa đã dùng thứ gì để dập lửa?',
          visualClueUrl: '',
          options: ['Vòi nước thần kỳ', 'Chiếc quạt mo', 'Cành cây'],
          optionEmojis: ['💧', '🪭', '🌿'],
          correctIndex: 0,
          celebrationTitle: 'Giỏi quá!',
          celebrationMessage: 'Chú chó đã cứu được ngôi nhà cây của các bạn!',
        ),
      ),
      const Story(
        id: 'story_3',
        title: 'Khu Vườn Của Ong Vàng',
        subtitle: 'Khám phá bí mật mật hoa',
        coverUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuDf3Tk84WeWhgHX1pHSLMVsCAYb0wd4mYJF9e2THfQ_dMG44GVPf_D1Ind_p0ga5qZasYVH8nteSidQzGhHhfjwLSzNk-TAE27fGMe37-nzioStOi4WCF2clzkBFuYk0gog3aGd4nbB4Lb2WmLJNf22qZC_vw7dyx6P1tnNKVM-GPGm-f_otlfyujoJ7Y1H1-hW5AtZ-V8cj2D3uNNvkyBVxtsn2kG7FdHnjzq34VW-bmLAYDgfvaTn',
        ageRange: '4 - 7 tuổi',
        category: 'Khoa học vui 🔬',
        totalPages: 8,
        currentPage: 4,
        isCompleted: false,
        pages: [],
        quiz: QuizQuestion(
          questionText: 'Ong mật lấy mật hoa bằng gì?',
          visualClueUrl: '',
          options: ['Vòi hút nhỏ', 'Hai chân trước', 'Đôi cánh'],
          optionEmojis: ['🍯', '🐾', '🪽'],
          correctIndex: 0,
          celebrationTitle: 'Rất chính xác!',
          celebrationMessage: 'Ong vàng chăm chỉ đã thu thập đầy hũ mật ngọt ngào!',
        ),
      ),
    ];

    currentStory = stories[0];
  }

  // State mutation methods
  void setCategory(String cat) {
    selectedCategory = cat;
    notifyListeners();
  }

  void addStars(int count) {
    stars += count;
    notifyListeners();
  }

  void setHeroCharacter(KidCharacter char) {
    heroCharacter = char;
    notifyListeners();
  }

  void setCompanionCharacter(KidCharacter char) {
    companionCharacter = char;
    notifyListeners();
  }

  void setCurrentStory(Story story) {
    currentStory = story;
    notifyListeners();
  }

  void addCharacter(KidCharacter newChar) {
    characters.insert(0, newChar);
    notifyListeners();
  }

  void approveCharacter(String charId) {
    final idx = characters.indexWhere((c) => c.id == charId);
    if (idx != -1) {
      characters[idx] = characters[idx].copyWith(isParentApproved: true);
      notifyListeners();
    }
  }

  void setScreenTimeLimit(int minutes) {
    screenTimeMinutesAllowed = minutes;
    notifyListeners();
  }

  // Drawing Canvas Methods
  void addStrokePoint(Offset point) {
    final paint = Paint()
      ..color = isEraserMode ? AppColors.surfaceContainerLowest : currentBrushColor
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..strokeWidth = isEraserMode ? (currentBrushSize * 2.5) : currentBrushSize;

    if (strokeLines.isEmpty) {
      strokeLines.add([DrawingPoint(offset: point, paint: paint)]);
    } else {
      strokeLines.last.add(DrawingPoint(offset: point, paint: paint));
    }
    notifyListeners();
  }

  void startNewStroke() {
    strokeLines.add([]);
    notifyListeners();
  }

  void undoStroke() {
    if (strokeLines.isNotEmpty) {
      strokeLines.removeLast();
      notifyListeners();
    }
  }

  void clearCanvas() {
    strokeLines.clear();
    notifyListeners();
  }

  void setBrushColor(Color color) {
    currentBrushColor = color;
    isEraserMode = false;
    notifyListeners();
  }

  void setBrushSize(double size) {
    currentBrushSize = size;
    notifyListeners();
  }

  void setEraserMode(bool enabled) {
    isEraserMode = enabled;
    notifyListeners();
  }

  void setScannerMode(bool isScanner) {
    isCameraScannerMode = isScanner;
    notifyListeners();
  }
}
