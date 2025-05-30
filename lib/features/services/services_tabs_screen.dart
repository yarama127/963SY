import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:untitled4/const.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:untitled4/features/home/models/category_model.dart';
import 'package:untitled4/features/places/presentation/pages/details/place_details_screen.dart';
import 'package:untitled4/features/services/cubit/city_cubit.dart';
import 'package:untitled4/features/services/cubit/place_service_cubit.dart';
import 'package:untitled4/features/services/cubit/service_cubit.dart';
import 'package:untitled4/features/services/cubit/star_cubit.dart';
import 'package:untitled4/l10n/app_localizations.dart';
import 'package:untitled4/core/widgets/rtl_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled4/models/place_model.dart';
import 'package:untitled4/navigation/navigation_service.dart';
import 'package:untitled4/features/home/presentation/pages/homepage.dart';
import 'package:untitled4/widgets/common/shimmer_effect/service_shimmer.dart';

class RedesignedServiceScreen extends StatefulWidget {
  const RedesignedServiceScreen({super.key, required this.category});
  final CategoryModel category;

  @override
  State<RedesignedServiceScreen> createState() =>
      _RedesignedServiceScreenState();
}

class _RedesignedServiceScreenState extends State<RedesignedServiceScreen> {
  final ScrollController _scrollController = ScrollController();

  late bool showStar = false;
  late int cityId;
  late int serviceId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Homepage()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: RTLText(
            text: l10n.services,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: BlocConsumer<CityCubit, CityState>(
            listener: (context, cityState) {
              if (cityState is CitySuccess) {
                log('Cubit sends success');
                cityId = cityState.cities.first.id!;
                context.read<ServiceCubit>().getCityServices(
                      cityId: cityState.cities.first.id!,
                      categoryId:
                          cityState.cities.first.categoriesIdcategories!,
                    );
              }
            },
            builder: (context, cityState) {
              if (cityState is CityLoading) {
                log('Cubit sends loading');
                return const LinearProgressIndicator(
                  color: AppColors.backgroundLight,
                );
              }
              if (cityState is CitySuccess) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RTLText(
                          text: l10n.findPlaces,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ).animate().fadeIn(duration: 500.ms),
                        const SizedBox(height: 5),
                        RTLText(
                          text: l10n.searchHint,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            height: 1.5,
                          ),
                        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // Filter Card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primary.withOpacity(0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildDropdownRow(
                              icon: Icons.location_on,
                              value: cityState.cities.first.cityName!,
                              items: cityState.cities
                                  .map((city) => city.cityName!)
                                  .toList(),
                              onChanged: (val) {
                                cityId = cityState.cities
                                    .where((city) => city.cityName == val)
                                    .single
                                    .id!;
                                log(cityId.toString());

                                setState(() {
                                  context.read<ServiceCubit>().getCityServices(
                                      cityId: cityId,
                                      categoryId: widget.category.id);
                                });
                              },
                              hint: l10n.selectGovernorate,
                            ),
                            const SizedBox(height: 14),
                            BlocBuilder<ServiceCubit, ServiceState>(
                              builder: (context, serviceState) {
                                if (serviceState is ServiceLoading) {
                                  return const Center(
                                      child: CircularProgressIndicator());
                                }
                                if (serviceState is ServiceSuccess) {
                                  if (serviceState.services.isEmpty) {
                                    return const Text('no services found');
                                  }
                                  return _buildDropdownRow(
                                    icon: Icons.category,
                                    value: serviceState.services.first.serName!,
                                    items: serviceState.services
                                        .map((service) => service.serName!)
                                        .toList(),
                                    onChanged: (val) {
                                      serviceId = serviceState.services
                                          .where((service) =>
                                              service.serName == val)
                                          .single
                                          .id!;
                                      showStar = serviceState.services
                                                  .where((service) =>
                                                      service.serName == val)
                                                  .single
                                                  .serType ==
                                              1
                                          ? true
                                          : false;
                                      setState(() {
                                        context
                                            .read<PlaceServiceCubit>()
                                            .getPlaceOfService(
                                                serviceId: serviceId,
                                                cityId: cityId,
                                                categoryId: widget.category.id);
                                        context.read<StarCubit>().getStars(
                                            serviceId: serviceId,
                                            cityId: cityId,
                                            categoryId: widget.category.id);
                                      });
                                    },
                                    hint: l10n.selectCategory,
                                  );
                                }
                                if (serviceState is ServiceFailuer) {
                                  return Text(serviceState.errorMessage);
                                }
                                return Container(
                                  child: const Text('some thig went wrong'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
                    const SizedBox(height: 15),
                    BlocConsumer<PlaceServiceCubit, PlaceServiceState>(
                      listener: (context, placeState) {
                        if (placeState is PlaceServiceSuccess) {}
                      },
                      builder: (context, placeState) {
                        if (placeState is PlaceServiceLoading) {
                          return const ServiceShimmer();
                        }
                        if (placeState is PlaceServiceSuccess) {
                          return Expanded(
                            child: placeState.placeOfServices.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        if (serviceId != 0) ...[
                                          Icon(
                                            Icons.search_off_rounded,
                                            size: 80,
                                            color: Colors.grey[400],
                                          ),
                                          const SizedBox(height: 10),
                                          RTLText(
                                            text: l10n.noResults,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ] else
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.category,
                                                size: 60,
                                                color: Colors.blueGrey[100],
                                              ),
                                              const SizedBox(height: 18),
                                              RTLText(
                                                text: l10n.chooseService,
                                                style: const TextStyle(
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.blueGrey,
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: [
                                      showStar
                                          ? BlocBuilder<StarCubit, StarState>(
                                              builder: (context, starState) {
                                                if (starState is StarsSuccess) {
                                                  return Card(
                                                    elevation: 3,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    margin:
                                                        const EdgeInsets.only(
                                                            bottom: 12),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 8),
                                                      child:
                                                          DropdownButtonFormField<
                                                              int>(
                                                        value: starState
                                                            .stars.first.id,
                                                        decoration:
                                                            InputDecoration(
                                                          labelText:
                                                              "selectStar",
                                                          prefixIcon:
                                                              const Icon(
                                                                  Icons.star,
                                                                  color: Colors
                                                                      .amber),
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                            borderSide:
                                                                BorderSide.none,
                                                          ),
                                                          filled: true,
                                                          fillColor:
                                                              Colors.grey[100],
                                                        ),
                                                        items: starState.stars
                                                            .map((e) =>
                                                                DropdownMenuItem<
                                                                    int>(
                                                                  value: e.id,
                                                                  child: Text(
                                                                      '${e.number} ★'),
                                                                ))
                                                            .toList(),
                                                        onChanged: (value) {
                                                          context
                                                              .read<
                                                                  PlaceServiceCubit>()
                                                              .getPlaceOfServiceByStar(
                                                                serviceId:
                                                                    serviceId,
                                                                cityId: cityId,
                                                                categoryId:
                                                                    widget
                                                                        .category
                                                                        .id,
                                                                starId: value!,
                                                              );
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                } else if (starState
                                                    is StarFailuer) {
                                                  return Text(
                                                      starState.errorMessage);
                                                } else {
                                                  return const Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }
                                              },
                                            )
                                          : const SizedBox(),
                                      const SizedBox(height: 10),
                                      Expanded(
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount:
                                              placeState.placeOfServices.length,
                                          itemBuilder: (context, index) {
                                            final item = placeState
                                                .placeOfServices[index];
                                            return GestureDetector(
                                              onTap: () {
                                                NavigationService.navigateTo(
                                                    '/details',
                                                    arguments: PlaceDetailsScreen(
                                                        place: Place
                                                            .fromServicePlace(
                                                                item)));
                                              },
                                              child: Card(
                                                margin: const EdgeInsets.only(
                                                    bottom: 16),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                ),
                                                elevation: 2,
                                                child: ListTile(
                                                  contentPadding:
                                                      const EdgeInsets.all(16),
                                                  leading: Container(
                                                    width: 130,
                                                    height: 90,
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: CachedNetworkImage(
                                                      imageUrl: item.photo!,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                  title: RTLText(
                                                    text: item.placeName!,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  subtitle: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4),
                                                    child: RTLText(
                                                      text: item.description!,
                                                      style: TextStyle(
                                                        color: Colors.grey[600],
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ).animate().fadeIn(
                                                    delay: Duration(
                                                        milliseconds: 600 +
                                                            (index * 100)),
                                                    duration: 500.ms,
                                                  ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                          );
                        }
                        return const Center(
                          child: RTLText(
                            text: 'اختر خدمة',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }
              if (cityState is CityFailuer) {
                log('cubit sends failed to load data : ${cityState.errorMessage}');
                return Text(cityState.errorMessage);
              }
              return const Text('some thing went wrong');
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownRow({
    required IconData icon,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    required String hint,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: DropdownButtonFormField<String>(
            value: items.contains(value) ? value : items.first,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ],
    );
  }
}
