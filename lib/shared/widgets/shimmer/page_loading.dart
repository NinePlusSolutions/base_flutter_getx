import 'package:flutter/material.dart';
import 'package:flutter_getx_boilerplate/shared/shared.dart';

class ShimmerPageLoading extends StatelessWidget {
  const ShimmerPageLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          ShimmerBaseWidget.image(
            width: double.infinity,
            height: 30.wp,
          ),
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                ShimmerBaseWidget.title(
                  lines: 1,
                  height: 12,
                ),
                ShimmerBaseWidget.title(
                  width: SizeConfig().screenWidth * 0.5,
                  lines: 1,
                  height: 12,
                ),
                Row(
                  children: [
                    ShimmerBaseWidget.title(
                      width: 80,
                      lines: 2,
                      height: 8,
                    ),
                    const Spacer(),
                    ShimmerBaseWidget.title(
                      width: 80,
                      lines: 1,
                      height: 8,
                    )
                  ],
                ),
              ],
            ),
          ),
          ..._item(),
          ..._item(),
          ..._item(),
        ],
      ),
    );
  }

  List<Widget> _item() {
    return [
      const Divider(
        height: 4,
        thickness: 6,
      ),
      Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ShimmerBaseWidget.atv(size: 40),
            const SizedBox(width: 8),
            ShimmerBaseWidget.title(
              width: 80,
              lines: 2,
              height: 8,
            )
          ],
        ),
      ),
      ShimmerBaseWidget.image(
        width: double.infinity,
        height: SizeConfig().screenHeight * 0.3,
      ),
      Padding(
        padding: const EdgeInsets.all(kDefaultPadding).copyWith(top: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ShimmerBaseWidget.title(
              width: 40,
              lines: 1,
              height: 8,
            ),
            ShimmerBaseWidget.title(
              width: 40,
              lines: 1,
              height: 8,
            ),
          ],
        ),
      ),
    ];
  }
}

class ListViewShimmerLoading extends StatelessWidget {
  const ListViewShimmerLoading({super.key, this.item});

  final Widget? item;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      padding: const EdgeInsets.all(0), //none
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (p1, p0) => const Divider(
        thickness: 2,
        height: 1,
      ),
      itemCount: 20,
      itemBuilder: (_, __) {
        if (item != null) return item!;
        return Padding(
          padding: const EdgeInsets.all(kDefaultPadding).copyWith(
            top: 4,
            bottom: 4,
          ),
          child: Row(
            children: [
              ShimmerBaseWidget.atv(size: 44),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBaseWidget.title(
                      width: 80,
                      lines: 1,
                      height: 8,
                    ),
                    ShimmerBaseWidget.title(
                      width: SizeConfig().screenWidth * 0.5,
                      lines: 1,
                      height: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                children: [
                  ShimmerBaseWidget.atv(size: 4),
                  ShimmerBaseWidget.atv(size: 4),
                  ShimmerBaseWidget.atv(size: 4),
                ],
              ),
              const SizedBox(width: 8),
            ],
          ),
        );
      },
    );
  }
}

class GripShimmerLoading extends StatelessWidget {
  const GripShimmerLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
      ),
      itemCount: 30,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          margin: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ShimmerBaseWidget.image(
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        ShimmerBaseWidget.atv(size: 30),
                        const SizedBox(width: 4),
                        ShimmerBaseWidget.title(
                          lines: 2,
                          width: 40,
                        ),
                      ],
                    ),
                  ),
                  ShimmerBaseWidget.title(
                    lines: 1,
                    width: 40,
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      },
    );
  }
}

class PostLoading {
  static Widget postListView() {
    return ListViewShimmerLoading(
      item: Container(
        // height: 150,
        width: double.infinity,
        padding: const EdgeInsets.all(kDefaultPadding),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBaseWidget.atv(size: 44),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBaseWidget.title(
                        width: 80,
                        lines: 1,
                        height: 8,
                      ),
                      ShimmerBaseWidget.title(
                        width: SizeConfig().screenWidth * 0.5,
                        lines: 1,
                        height: 8,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ShimmerBaseWidget.atv(size: 6),
                    ShimmerBaseWidget.atv(size: 6),
                    ShimmerBaseWidget.atv(size: 6),
                  ],
                )
              ],
            ),
            const SizedBox(height: 8),
            ShimmerBaseWidget.title(
              width: SizeConfig().screenWidth * 0.5,
              lines: 1,
              height: 12,
            ),
            ShimmerBaseWidget.title(
              width: SizeConfig().screenWidth * 0.8,
              lines: 2,
              height: 8,
            ),
          ],
        ),
      ),
    );
  }

  static Widget postInfo() {
    return _PostInfoLoading();
  }

  static Widget comments() {
    return ListViewShimmerLoading(
      item: Container(
        // height: 150,
        width: double.infinity,
        padding: const EdgeInsets.all(kDefaultPadding),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade300,
              width: 1,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerBaseWidget.atv(size: 44),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShimmerBaseWidget.title(
                            width: 40,
                            lines: 1,
                            height: 8,
                          ),
                          const SizedBox(width: 8),
                          ShimmerBaseWidget.title(
                            width: 80,
                            lines: 1,
                            height: 8,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ShimmerBaseWidget.title(
                        width: SizeConfig().screenWidth * 0.5,
                        lines: 2,
                        height: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PostInfoLoading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          height: 20,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          width: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
            ),
            const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
            ),
            const CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
            ),
            const SizedBox(width: 8),
            Container(
              height: 12,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          color: context.colors.surface,
          child: const ListTile(),
        ),
        const SizedBox(height: 4),
        Container(
          color: context.colors.surface,
          child: const ListTile(),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Row(
            children: [
              Container(
                height: 24,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                height: 24,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
