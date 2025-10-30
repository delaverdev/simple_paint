import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cupertino_color_picker/cupertino_color_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_paint/core/services/notifications_service.dart';
import 'package:simple_paint/domain/models/draw.dart';
import 'package:simple_paint/features/utils/utils.dart';
import 'package:simple_paint/features/viewmodels/draws.dart';

import '../../../domain/models/draw_stroke.dart';
import '../../../domain/models/draw_tool.dart';
import '../widgets/draw_canvas_painter.dart';
import '../widgets/home_nav_bar.dart';
import '../widgets/home_nav_button.dart';

class DrawScreen extends ConsumerStatefulWidget {
  const DrawScreen({super.key, this.initialDraw});

  final Draw? initialDraw;

  @override
  ConsumerState<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends ConsumerState<DrawScreen> {
  final GlobalKey _repaintKey = GlobalKey();

  Uint8List? _bgBytes;
  ui.Image? _bgImage;

  late final List<DrawStroke> _strokes;
  DrawStroke? _currentStroke;

  DrawTool _tool = DrawTool.pen;
  Color _penColor = CupertinoColors.black;
  final double _penWidth = 5;

  late final _drawsModel = ref.read(drawsModelProvider);

  final GlobalKey shareAnchorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.initialDraw != null) {
      _strokes = List<DrawStroke>.from(widget.initialDraw!.strokes);
      _bgBytes = widget.initialDraw!.backgroundImageBytes;
      _loadBackgroundImage();
    } else {
      _strokes = [];
    }
  }

  Future<void> _loadBackgroundImage() async {
    if (_bgBytes != null) {
      final codec = await ui.instantiateImageCodec(_bgBytes!);
      final frame = await codec.getNextFrame();
      if (mounted) {
        setState(() {
          _bgImage = frame.image;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          Image.asset(
            'assets/images/bg.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          SafeArea(
            top: false,
            child: Column(
              children: [
                HomeNavBar(
                  title: widget.initialDraw != null
                      ? 'Редактирование'
                      : 'Новое изображение',
                  leading: HomeNavButton(
                    icon: SvgPicture.asset('assets/icons/back.svg'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  trailing: HomeNavButton(
                    icon: Image.asset('assets/icons/check.png'),
                    onPressed: _saveDraw,
                  ),
                ),
                Container(
                  height: 38,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      _buildActionButton(
                        iconPath: 'assets/icons/save.svg',
                        onPressed: _saveAsPng,
                        key: shareAnchorKey,
                      ),
                      _buildActionButton(
                        iconPath: 'assets/icons/gallery.svg',
                        onPressed: _pickBackground,
                      ),
                      _buildActionButton(
                        iconPath: 'assets/icons/pen.svg',
                        onPressed: () => setState(() => _tool = DrawTool.pen),
                        isActive: _tool == DrawTool.pen,
                      ),
                      _buildActionButton(
                        iconPath: 'assets/icons/erase.svg',
                        onPressed: () =>
                            setState(() => _tool = DrawTool.eraser),
                        isActive: _tool == DrawTool.eraser,
                      ),
                      _buildActionButton(
                        iconPath: 'assets/icons/palette.svg',
                        onPressed: _pickColor,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: RepaintBoundary(
                      key: _repaintKey,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onPanStart: (details) {
                              final rb =
                                  _repaintKey.currentContext?.findRenderObject()
                                      as RenderBox?;

                              final p =
                                  rb?.globalToLocal(details.globalPosition) ??
                                  details.localPosition;

                              _currentStroke = DrawStroke(
                                tool: _tool,
                                color: _penColor,
                                width: _penWidth,
                              )..path.moveTo(p.dx, p.dy);

                              setState(() => _strokes.add(_currentStroke!));
                            },
                            onPanUpdate: (details) {
                              final rb =
                                  _repaintKey.currentContext?.findRenderObject()
                                      as RenderBox?;

                              final p =
                                  rb?.globalToLocal(details.globalPosition) ??
                                  details.localPosition;

                              setState(
                                () => _currentStroke?.path.lineTo(p.dx, p.dy),
                              );
                            },
                            onPanEnd: (_) => _currentStroke = null,
                            child: CustomPaint(
                              painter: DrawCanvasPainter(
                                bgImage: _bgImage,
                                strokes: _strokes,
                              ),
                              child: Container(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const Spacer(flex: 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String iconPath,
    required VoidCallback onPressed,
    bool isActive = false,
    Key? key,
  }) {
    return Container(
      key: key,
      width: 38,
      height: 38,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      child: CupertinoButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        child: Container(
          decoration: BoxDecoration(
            color: (isActive
                ? CupertinoColors.white.withOpacity(0.35)
                : CupertinoColors.white.withOpacity(0.2)),
            shape: BoxShape.circle,
            border: isActive ? Border.all(color: Colors.white, width: 1) : null,
          ),
          alignment: Alignment.center,
          child: SvgPicture.asset(iconPath, width: 24, height: 24),
        ),
      ),
    );
  }

  Future<void> _saveDraw() async {
    Utils.showLoadingDialog(context: context, message: 'Сохранение');
    try {
      if (widget.initialDraw != null) {
        final result = await _drawsModel.updateDraw(
          drawId: widget.initialDraw!.id,
          strokes: _strokes,
          backgroundImage: _bgBytes,
        );

        if (result != null) {
          final drawWithImage = result.copyWith(backgroundImageBytes: _bgBytes);
          ref.read(drawsStateProvider.notifier).updateDrawInList(drawWithImage);
          Utils.hideLoadingDialog(context);

          await NotificationsService.instance.showNow(
            title: 'Simple Paint',
            body: 'Рисунок успешно сохранен.',
          );

          Navigator.of(context).pop();
        } else {
          Utils.hideLoadingDialog(context);
          Utils.showErrorDialog(
            context: context,
            title: 'Ошибка',
            message: 'Ошибка обновления рисунка. Попробуйте еще раз.',
          );
        }
      } else {
        final result = await _drawsModel.createDraw(
          strokes: _strokes,
          backgroundImage: _bgBytes,
        );

        if (result != null) {
          final drawWithImage = result.copyWith(backgroundImageBytes: _bgBytes);
          ref.read(drawsStateProvider.notifier).addDrawToList(drawWithImage);
          Utils.hideLoadingDialog(context);

          await NotificationsService.instance.showNow(
            title: 'Simple Paint',
            body: 'Рисунок успешно сохранен.',
          );

          Navigator.of(context).pop();
        } else {
          await NotificationsService.instance.showNow(
            title: 'Simple Paint',
            body: 'Произошла ошибка сохранения рисунка.',
          );

          Utils.hideLoadingDialog(context);
          Utils.showErrorDialog(
            context: context,
            title: 'Ошибка',
            message: 'Ошибка создания рисунка. Попробуйте еще раз.',
          );
        }
      }
    } catch (e) {
      await NotificationsService.instance.showNow(
        title: 'Simple Paint',
        body: 'Произошла ошибка сохранения рисунка.',
      );

      Utils.hideLoadingDialog(context);
      Utils.showErrorDialog(
        context: context,
        title: 'Ошибка',
        message: 'Произошла неизвестная ошибка. Попробуйте еще раз.',
      );
    }
  }

  Future<void> _pickBackground() async {
    try {
      final permission = await Permission.photos.status;

      if (permission.isDenied) {
        final result = await Permission.photos.request();
        if (result.isDenied) {
          if (mounted) {
            Utils.showErrorDialog(
              context: context,
              title: 'Доступ к галерее',
              message:
                  'Для выбора изображения необходимо разрешение на доступ к галерее.',
            );
          }
          return;
        }
      }

      if (permission.isPermanentlyDenied) {
        if (mounted) {
          Utils.showErrorDialog(
            context: context,
            title: 'Доступ к галерее',
            message:
                'Доступ к галерее заблокирован. Разрешите доступ в настройках приложения.',
          );
        }
        return;
      }

      final picker = ImagePicker();
      final x = await picker.pickImage(source: ImageSource.gallery);
      if (x == null) {
        return;
      }

      final bytes = await x.readAsBytes();

      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final img = frame.image;

      if (mounted) {
        setState(() {
          _bgBytes = bytes;
          _bgImage = img;
        });
        print('Background image set in state');
      }
    } catch (e) {
      if (mounted) {
        Utils.showErrorDialog(
          context: context,
          title: 'Ошибка',
          message: 'Произошла неизвестная ошибка. Попробуйте еще раз.',
        );
      }
    }
  }

  Future<void> _saveAsPng() async {
    try {
      //Делаем "скрин" рендер обжекта холста
      final boundary =
          _repaintKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return;
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      if (byteData == null) return;

      //Пишем файл в временную папку
      final bytes = byteData.buffer.asUint8List();
      final dir = await getTemporaryDirectory();
      final file = File(
        '${dir.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes, flush: true);

      if (!mounted) return;

      //Шарим
      RenderBox box =
          shareAnchorKey.currentContext?.findRenderObject() as RenderBox;

      final params = ShareParams(
        files: [XFile(file.path)],
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
      );

      await SharePlus.instance.share(params);
    } catch (e) {
      Utils.showErrorDialog(
        context: context,
        title: 'Ошибка',
        message: 'Произошла ошибка выгрузки картинки. Попробуйте еще раз.',
      );
    }
  }

  Future<void> _pickColor() async {
    final color = await showCupertinoColorPicker(
      initialColor: _penColor,
      supportsAlpha: true,
    );

    if (color != null) {
      setState(() {
        _penColor = color;
        print('Color changed to: ${color.toString()}');
      });
    }
  }
}
