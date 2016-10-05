# Dism commands used to update win-2012 iso image to produce slipstream image.
# This was put together based on this article: https://4sysops.com/archives/use-dism-to-slipstream-updates/
# The actual list of DISM files was put together using trial and error (i.e. filter out failing issues)
# WSUS server was also used to ensure full updates (and not express-cab files) were used.


$DownloadPath = "C:\Win-2012-Dist\Download"
$ImageMount   = "E:\Mount"
$WinDistPath  = "c:\WIn-2012-Dist\Windows_2012"
$WinISOFile   = "c:\WIn-2012-Dist\Win-2012-Slipstream.iso"

# Mount the image

dism /mount-wim /wimfile:"$WinDistPath\sources\install.wim" /index:2 /mountdir:"$ImageMount"

# Apply DISM commands individually - in future this will be written into a procedure to:
# 1. Scan the directory
# 2. Commit every 5-10 updates (so we can easily rollback from error)
# 3. Record errors and stop.
# etc. etc.

DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\024398f7a9c8f5b6ccc78bc25a237b28\windows8-rt-kb2813430-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\045e4ecf40acd3bc74b87038217aba9c\windows8-rt-kb2871997-v6-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\04c89dcc699a04fb95a890bf95ba178f\windows8-rt-kb3077715-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\0571f189792595db15d880a53b03ff63\windows8-rt-kb3013767-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\07b1a1a04d272ef8cc638b005a4b812a\windows8-rt-kb2836988-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\088bc3eff031b1d29a8d86b414763c53\windows8-rt-kb2850674-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\099a9e9ce296c9487554186ee283b952\windows8-rt-kb3037580-v2-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\0a6db58b217e3b23fd13356ca3650b15\windows8-rt-kb3019978-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\0b3b464151f420e82fdc1a40f17f8205\windows8-rt-kb3074549-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\0bf238f1416b1a0a64fd53f5bbd28dea\windows8-rt-kb2855336-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\0c578e99f97d8610ae212c66b52aca28\windows8-rt-kb2862330-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\0df940e2e67b3cf142c1722d62fd85d3\windows8-rt-kb3126593-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\0e47b393e7fe6142bf3f0bc542fb853f\windows8-rt-kb3004361-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\0e75cdac7d68a564131bdea5be33d7dc\windows8-rt-kb2861702-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\12caf4c0790714ca140aebdcc25e800e\windows8-rt-kb3086255-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\13df956d820826b486e40d34bf87b1c4\windows8-rt-kb2862152-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\147aaa6df79ccc749bdddf9d04d8e37f\windows8-rt-kb2777166-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\148882d6af48bddbaa62ba744f0f399a\windows8-rt-kb2823516-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\1566aa15369f8440648701315524b3fd\windows8-rt-kb2973201-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\1967b32aaedd90e0aaffb2541dc3fe0b\windows8-rt-kb2862966-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\1c1a030ed510c9504073437f2c1f88eb\windows8-rt-kb3059317-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\1ee9c8007920f70cb20c0fd242efc557\windows8-rt-kb2893294-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\1f5d305bcd8c92f5f0ad2e486aca52e7\windows8-rt-kb3133043-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\22eaec80856d8c44c234a79ce72696d0\windows8-rt-kb2876415-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\275716133439ebde3013b37142c41f86\windows8-rt-kb2984005-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\27d570adf20f8057846cdf4126535f00\windows8-rt-kb2795944-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\298813facb7a2d3d32167c2047489511\windows8-rt-kb3003743-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\2a8ad5a1b5bdff79b5b92c63e2da9a22\windows8-rt-kb2883201-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\2f1dc431073c1abc1aa3623e526768cd\windows8-rt-kb3108347-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\2f4c9dcd322ec13734368c14ea202335\windows8-rt-kb2977292-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\3250d76ef91c5dd054587356fed28baa\windows8-rt-kb3011780-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\36dc6bca36e32c2ce666352b3ff1791b\windows8-rt-kb3076895-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\36f7390f54afd02709c30d46487c42bb\windows8-rt-kb2934016-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\3856ba4892be1f53513c0ced3979fc48\windows8-rt-kb2862768-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\3aa8bdc985bc2db13c1a7c90bed2b113\windows8-rt-kb3080446-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\3c3555ce952e1a5a7dac2ee73d67fe03\windows8-rt-kb2868626-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\3e06e5d785e2c68e04f1f20a0c2d3bb9\windows8-rt-kb3109094-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\3e28b9501903e8c5723f4b8e55d15df8\windows8-rt-kb2979577-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\4216368c77401946d575ee2874b39b21\windows8-rt-kb3074229-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\427e646d5ea1749affe4446642e93f05\windows8-rt-kb2977766-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\437466ccd3e617bf06785fab14f4ace2\windows8-rt-kb3156017-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\439cc77b85b2576bf4419bc570895c1c\windows8-rt-kb2862073-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\44740b3d9703f26701b61b7fb98ce659\windows8-rt-kb3151058-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\457647f4c25c5eb118424c35651c87ef\windows8-rt-kb3078601-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\48e940cf3cda123e0aac9d98028725a7\windows8-rt-kb3004365-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\4b223357e138e1fc0aaab70222267143\windows8-rt-kb3146706-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\4b2a90532c4d5310d99ae65c60ab5a02\windows8-rt-kb2999323-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\4c6931264ccd23150706fd729ee11fd1\windows8-rt-kb3042553-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\509304c3734e57c4d6d360c974c34f88\windows8-rt-kb2868038-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\52571c5dc944624539f8bae7d43009fb\windows8-rt-kb2737084-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\53714df14a72eea3f86e3cc0d1b694f8\windows8-rt-kb2884256-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\54524f20a7c9110cd58f778d720a2d92\windows8-rt-kb3010788-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log

DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\58d326f3ca8af6fb2e6bdd995a171e4a\windows8-rt-kb3140735-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\59c951d79809a0b138b6438effec8d56\windows8-rt-kb2993651-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\5cec2450f97701cac52c3db440ceb90e\windows8-rt-kb3109103-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\5d9edea65250c6f325aff05717916c12\windows8-rt-kb3072630-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\5e43aa42b90f6fef5ee974aa1965c53b\windows8-rt-kb3123479-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\609f746f78f83f3a2449260a2f211b0a\windows8-rt-kb3148198-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\616099036cfeb109e848132e6df400d6\windows8-rt-kb2840632-v2-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\629de850ef28b3f2a0e29e8ce8d19a40\windows8-rt-kb3126446-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\62ce8e0584ada0cd5703eaeb9e1c4029\windows8-rt-kb2871389-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\66f978e263d5de45076a28c052dd7777\windows8-rt-kb2978042-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\675331ae0cb5c4d65d7d2a78d593250a\windows8-rt-kb2798162-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\69f00f7f5a00a81bce92c5cf0c37b7c6\windows8-rt-kb2758246-v2-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\6a528d4a98e35441d7ae48bdca146b35\windows8-rt-kb3126587-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\6b3d61aee446afed354b667c783d1e9a\windows8-rt-kb3023223-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\6e140ec193fbadb971186580a4adadd2\windows8-rt-kb2769165-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\7054a20a1c8c2057df979fc533bf65a3\windows8-rt-kb2995387-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\71bf5fe2fe2c5238ead47220b80db939\windows8-rt-kb3004375-v5-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\79da0a77d679b2f207451996abfc5c59\windows8-rt-kb3035489-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\7aa8c9a8161a0daaf8f87f58d25fa73a\windows8-rt-kb3108381-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\7ce354c9cd29135e03a7dcf245b7880f\windows8-rt-kb2756872-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\80e2d910504726c05afda250ba4d807f\windows8-rt-kb3021674-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\823f69b48caa2d565d17508ac0122749\windows8-rt-kb3156016-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\85932643c90c0498263f0303ff003e2d\windows8-rt-kb2973501-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\8614ee4b4127cbfd74e66f863ff0916d\windows8-rt-kb2903938-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\870ce7929df8b2d6c5e395c24c4960e8\windows8-rt-kb3098780-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\874319c80af84097555a5e452c65ccd6\Windows8-RT-KB2764870-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\88ab908c7cedc80a9538fd19d49f8bce\windows8-rt-kb2770660-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\8b0b44dea2d0514d009733004f68721a\windows8-rt-kb2742614-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\8bb43b35f45a8af84282f3a5562d84a5\windows8-rt-kb3137513-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\8bba2d468044f85913bea5f7b116e7c2\windows8-rt-kb2853915-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\8bd0e9133bf50e5c3129b4c8a044c342\windows8-rt-kb3068457-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\8c863fcb0c45d58b90503e3b802a31f4\windows8-rt-kb2800088-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\8e36aa7fc1337b06d34053f16249d36f\windows8-rt-kb3110329-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\8e3f28581bccf4b1e22837ec8b7d8ef2\windows8-rt-kb2779768-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\8fc199b6e60fe58c847353f591696fb1\windows8-rt-kb3097995-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\8fdd4711caf49e4de073e797c2d9b450\windows8-rt-kb2892074-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\901da5bb4d356c0c3bdf96fcfd366a4d\windows8-rt-kb3153199-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\9299abfe0cca2e6caee26e96072a4111\Windows8-RT-KB2851234-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\934e836fc640b03ae5926cff2cc51a89\windows8-rt-kb3092601-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\9458fd3793a934764aa8876b29eda886\windows8-rt-kb3031432-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\94d87cffadda1b7aab245a3a2cf37780\windows8-rt-kb2811660-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\97129d3133aef63d0f9da4932125619f\windows8-rt-kb2803676-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\97c63d4a30d9fe2822007811085a2349\windows8-rt-kb3084135-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\992481bb991b3edc1434727236da90d6\windows8-rt-kb2992611-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\9aefe16f5ca3281bf521c00a0bd93608\windows8-rt-kb2877211-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\9be7570b82f2f0671bdea87c55397422\Windows8-RT-KB3018238-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\9c797df45f7cc353b30223110feea5f1\windows8-rt-kb2862335-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\9c8f123572f31bb4aaf4590066dd879d\windows8-rt-kb3156019-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\a036301e9aa6fa042eeccefcb68b1240\windows8-rt-kb3139398-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\a06587fad31d32c50685a6f4b6ce1701\windows8-rt-kb3153704-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\a0dfc19eec0528dba0e1a92e763cba99\windows8-rt-kb3153171-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\a1fdca5748ce0a036a6c2921b43f9226\windows8-rt-kb2920189-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\a412e83f47d00a43a14f87dc9928929f\windows8-rt-kb3139940-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\a471481247859abb86e3c5ba768576ba\windows8-rt-kb2889784-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\a50659d799059e16f751d98f1763ce18\windows8-rt-kb2912390-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\a9376aa867325c8cfabe9ad0f9d3dd05\windows8-rt-kb3139914-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\a9f955ce51422ffb998f0d930124d4d9\windows8-rt-kb3022777-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\aacbb78cdc7ca76d3d60c188d1f246e5\windows8-rt-kb3035126-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\acda3b7ae5494ff7c3e7b4c57c03e210\windows8-rt-kb3082089-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\ad83443995933a63911b01152d9e8471\windows8-rt-kb3071756-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\ae47f3d784a754b125d073a192fc865e\windows8-rt-kb2975331-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\ae7bce33971d624b718417577aa09c79\windows8-rt-kb2849568-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\aed1c4edf072c349e5490aa29cc4d080\windows8-rt-kb3097966-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\b0d53efff90fdbc805bdb4c36f50ff99\windows8-rt-kb3075220-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\b1b89a76abe3192ab81ec8a59a6b82d9\windows8-rt-kb2894855-v2-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\b39ae018ff40711cd134cd68554835f3\windows8-rt-kb3067505-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\b4abca0a6372062de13cc2407cb18a21\windows8-rt-kb2922229-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\b6c3958d00d362834b082bcfba7afcf5\windows8-rt-kb2802618-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\b7773dc04a4d1e441a0bc346e919e820\windows8-rt-kb2845533-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\bbca73df9106250803b3e96ca57ad3ea\windows8-rt-kb3087039-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\bbe3170831c29d9ecb2328d95b0a0e69\windows8-rt-kb2928678-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\c029767f5d79104b8173df7ff6e24080\windows8-rt-kb2863725-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\c15e4078e9c7055a6ccd7ff6e73f6576\windows8-rt-kb3156013-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\c2f939b16737af79af91eec24a9d8536\windows8-rt-kb3045685-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\c6824cc7387b78c19958ad3670bdfd52\windows8-rt-kb3081320-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\c9b7adc3b99ad721cc3762048d0fdcd6\windows8-rt-kb2761094-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\cb520f68fe36393b2121af554cb5413e\windows8-rt-kb2807986-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\cb886d7162a590d56c306c6c26512e37\windows8-rt-kb2911101-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\cc6e93a2416c12f35fae5685762f7b80\windows8-rt-kb3000853-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\cffe5b8ca1e535b72e14d5d235963800\windows8-rt-kb2812829-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\d1e791e78070531f447563a2e07b8c58\windows8-rt-kb2785094-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\d31989bc7d151806f84b7dadfd59cd3d\windows8-rt-kb3083992-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\d4ca6dfcce6d42fb9f14285033e9eca1\windows8-rt-kb3030377-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\d55c7f256d2fccda7c22e2f96a62e783\windows8-rt-kb2784160-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\d7c519a4a61e9b9f2d2f848952218080\windows8-rt-kb3135456-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\d7dc809798eb5655f4c59d8a733bf61a\windows8-rt-kb3033889-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\d7eda9cd2e1e2cf40321696af2984b94\windows8-rt-kb2839894-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\d95ac8c735624ee0bb34e39df28938f1\windows8-rt-kb3155784-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\dbd5536d9ee065faae6f08262799b06a\windows8-rt-kb2973351-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\dc53dbc6f964c3bb955c07f5b719eb93\windows8-rt-kb2866029-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\df818fd57a27e36fa287db206abbf6c8\windows8-rt-kb3088195-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\e103458da7fa90f0e159b33f0df036df\windows8-rt-kb2993651-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\e1ebf34e07722d3cf74687887d64f746\windows8-rt-kb2856758-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\e3c2d64477daea820991275ce9c173e2\windows8-rt-kb3006226-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\e798b44ce6d44526f3ef212417ae7d26\windows8-rt-kb2770917-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\ebe985658b207be7c56f864f8b025915\windows8-rt-kb3146723-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\ecc797411e69b85c3938ccfe80567d55\windows8-rt-kb2898865-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\efe25fdcbf68e6fae8f6287f7f1e9bb8\windows8-rt-kb3004375-v5-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\efe9b1466926c1e58b7bca1d0c3a6e73\windows8-rt-kb2815769-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\f052908ae762974414db5e999a12c45b\Windows8-RT-KB2996928-v2-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\f0e179df09174038ad10e658c6c6aac7\windows8-rt-kb2822241-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\f21719844b64af54a9955dc0bd34ac6e\windows8-rt-kb3146963-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\f21eb5b9103bb2f1d806fdfe3c122cf7\Windows8-RT-KB2985485-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log
DISM /image:"$ImageMount" /add-package /packagepath:"$DownloadPath\f2f72474561071f976836b0d5910e2e2\windows8-rt-kb3003729-x64.cab"  /loglevel:1 /logpath=.\dism-slip.log


# Dismount and Commit the Image

dism /unmount-wim /mountdir:"$ImageMount" /commit

# Write the ISO Image
# Need WAIK in path for this to work - for reference only.
# Powershell may need a bit of tidying to handle windist variables.
# May also be preferable to pick up boot files from WAIK, tho these files on the dist appear to work ok.
# See https://support.microsoft.com/en-us/kb/947024 for further information on how to create an ISO file.

oscdimg -m -o -u2 -udfver102 -bootdata:"2#p0,e,b$WinDistPath\boot\etfsboot.com#pEF,e,b$WinDistPath\efi\microsoft\boot\efisys.bin"   $WinDistPath $WinISOFile
