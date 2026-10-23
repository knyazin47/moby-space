import '../../core/config/demo_artwork.dart';
import '../models/bank_models.dart';
import '../models/money.dart';

/// Public content belongs to the scenario, independently of screen styling.
final class DemoBanner {
  const DemoBanner({
    required this.id,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.route,
    required this.assetPath,
    this.observedIndex = 0,
  });

  final int observedIndex;
  final String assetPath;
  final String id;
  final String title;
  final String description;
  final String actionLabel;
  final String route;
}

final class DemoProduct {
  const DemoProduct({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.route,
  });

  final String id;
  final String title;
  final String description;
  final String iconName;
  final String route;
}

final class DemoMenuItem {
  const DemoMenuItem({
    required this.id,
    required this.title,
    required this.iconName,
    required this.route,
  });

  final String id;
  final String title;
  final String iconName;
  final String route;
}

final class DemoScenario {
  DemoScenario({
    required this.initialSnapshot,
    required this.actionTime,
    required Iterable<DemoBanner> homeBanners,
    required Iterable<DemoBanner> productBanners,
    this.sourceProductBannerIndicatorCount = 14,
    required Iterable<DemoProduct> products,
    required Iterable<DemoProduct> applyProducts,
    required Iterable<DemoMenuItem> moreItems,
  }) : homeBanners = List.unmodifiable(homeBanners),
       productBanners = List.unmodifiable(productBanners),
       products = List.unmodifiable(products),
       applyProducts = List.unmodifiable(applyProducts),
       moreItems = List.unmodifiable(moreItems);

  final BankSnapshot initialSnapshot;

  /// A fixed local-demo clock. Actions advance by one minute from this value.
  final DateTime actionTime;
  final List<DemoBanner> homeBanners;
  final List<DemoBanner> productBanners;

  /// Legacy catalog metadata. The demo keeps six pages with its own artwork;
  /// runtime dots match available pages, without dead navigation targets.
  final int sourceProductBannerIndicatorCount;
  int get productBannerIndicatorCount => productBanners.length;
  final List<DemoProduct> products;
  final List<DemoProduct> applyProducts;
  final List<DemoMenuItem> moreItems;
}

const primaryAccountId = 'account-byn-main';
const primaryCardId = 'card-main';

/// Personal/financial values are invented; illustrations are project-owned.
/// No account data is imported from the reference app.
DemoScenario createDemoScenario() => DemoScenario(
  actionTime: DateTime.utc(2026, 10, 19, 12),
  initialSnapshot: BankSnapshot(
    profile: const DemoProfile(
      id: 'profile-demo',
      firstName: 'Иван',
      lastName: 'Демин',
      phone: '+375 •• ••• 18 42',
    ),
    accounts: [
      DemoAccount(
        id: primaryAccountId,
        title: 'Основной счёт',
        maskedNumber: 'BY•• •••• •••• 6284',
        balance: Money(248631),
      ),
      DemoAccount(
        id: 'account-usd',
        title: 'Счёт в долларах',
        maskedNumber: 'BY•• •••• •••• 3097',
        balance: Money(31540, currency: 'USD'),
      ),
    ],
    cards: [
      DemoCard(
        id: primaryCardId,
        accountId: primaryAccountId,
        title: 'КАКТУС BYN',
        paymentSystem: 'Mastercard',
        artAssetPath: DemoArtwork.wallet,
        lastFour: '4286',
        holderName: 'IVAN DEMIN',
        expiresAt: DateTime.utc(2029, 8),
      ),
      DemoCard(
        id: 'card-usd',
        accountId: 'account-usd',
        title: 'Валютная карта',
        paymentSystem: 'Mastercard',
        lastFour: '1094',
        holderName: 'IVAN DEMIN',
        expiresAt: DateTime.utc(2028, 11),
      ),
    ],
    operations: [
      DemoOperation(
        id: 'fixture-operation-1',
        status: OperationStatus.pending,
        sourceAmount: Money(1249, currency: 'EUR'),
        mcc: 5411,
        accountId: primaryAccountId,
        title: 'Маркет «У дома»',
        subtitle: 'Продукты',
        amount: Money(4387),
        direction: OperationDirection.outgoing,
        category: OperationCategory.groceries,
        occurredAt: DateTime.utc(2026, 10, 19, 9, 24),
      ),
      DemoOperation(
        id: 'fixture-operation-2',
        accountId: primaryAccountId,
        title: 'Городской транспорт',
        subtitle: 'Транспорт',
        amount: Money(180),
        direction: OperationDirection.outgoing,
        category: OperationCategory.transport,
        occurredAt: DateTime.utc(2026, 10, 19, 8, 10),
      ),
      DemoOperation(
        id: 'fixture-operation-3',
        accountId: primaryAccountId,
        title: 'ЗАЧИСЛЕНИЕ СРЕДСТВ',
        typeLabel:
            'Пополнение счета\nТекущий счет BY•• •••• •••• 6284\nза 18.10.2026',
        subtitle: 'Зачисление на счёт',
        amount: Money(125000),
        direction: OperationDirection.incoming,
        category: OperationCategory.income,
        occurredAt: DateTime.utc(2026, 10, 18, 16, 35),
      ),
      DemoOperation(
        id: 'fixture-operation-4',
        accountId: primaryAccountId,
        title: 'Магазин «Лист»',
        subtitle: 'Покупки',
        amount: Money(2790),
        direction: OperationDirection.outgoing,
        category: OperationCategory.shopping,
        occurredAt: DateTime.utc(2026, 10, 17, 13, 5),
      ),
    ],
  ),
  homeBanners: const [
    DemoBanner(
      id: 'banner-currency',
      title: 'Обменник Moby',
      description: 'Обмен валют по выгодному курсу',
      assetPath: DemoArtwork.allowance,
      actionLabel: 'Посмотреть',
      route: '/currency',
    ),
    DemoBanner(
      id: 'banner-local-demo',
      title: 'Пакет услуг',
      description: 'Оформите МТкарту, чтобы получать дополнительные бонусы',
      assetPath: DemoArtwork.familyIntro,
      actionLabel: 'Подробнее',
      route: '/apply-card',
    ),
  ],
  productBanners: const [
    DemoBanner(
      id: 'product-promo-0',
      title: 'Рекламная игра с Халвой',
      description: 'На шопинг с Халвой! Главный приз — 10 000 BYN.',
      actionLabel: 'Подробнее',
      route: '/offers/product-promo-0',
      observedIndex: 0,
      assetPath: DemoArtwork.reward,
    ),
    DemoBanner(
      id: 'product-promo-1',
      title: 'Золотое Яблоко',
      description:
          'Покупать онлайн в Золотом Яблоке стало ещё удобнее. Теперь с Халвой.',
      actionLabel: 'Подробнее',
      route: '/offers/product-promo-1',
      observedIndex: 1,
      assetPath: DemoArtwork.goal,
    ),
    DemoBanner(
      id: 'product-promo-2',
      title: 'Халва на Kufar',
      description: '+1 месяц по Халве',
      actionLabel: 'Подробнее',
      route: '/offers/product-promo-2',
      observedIndex: 2,
      assetPath: DemoArtwork.wallet,
    ),
    DemoBanner(
      id: 'product-promo-3',
      title: 'Халва на Wildberries',
      description: 'Покупайте без переплат! 5 месяцев.',
      actionLabel: 'Подробнее',
      route: '/offers/product-promo-3',
      observedIndex: 3,
      assetPath: DemoArtwork.allowance,
    ),
    DemoBanner(
      id: 'product-promo-4',
      title: 'Халва с базовым счётом',
      description:
          'Оформляйте Халву всего за 10 BYN в год. Предложение для пенсионеров с базовым счётом в МТБанке.',
      actionLabel: 'Подробнее',
      route: '/offers/product-promo-4',
      observedIndex: 4,
      assetPath: DemoArtwork.learning,
    ),
    DemoBanner(
      id: 'product-promo-5',
      title: 'Халва зарплатным клиентам',
      description:
          'Оформи Халву и получи бесплатное обслуживание на первый год',
      actionLabel: 'Подробнее',
      route: '/offers/product-promo-5',
      observedIndex: 5,
      assetPath: DemoArtwork.familyIntro,
    ),
  ],
  products: const [
    DemoProduct(
      id: 'product-card',
      title: 'Карты и счета',
      description: 'Ваши карты и счета',
      iconName: 'credit_card',
      route: '/cards',
    ),
    DemoProduct(
      id: 'product-credit',
      title: 'Кредиты',
      description: 'Ваши кредитные продукты',
      iconName: 'payments',
      route: '/products/credits',
    ),
    DemoProduct(
      id: 'product-deposit',
      title: 'Вклады',
      description: 'Ваши сбережения и вклады',
      iconName: 'savings',
      route: '/products/deposits',
    ),
    DemoProduct(
      id: 'product-requests',
      title: 'Заявки на продукты',
      description: 'Ваши заявки на кредитные и иные продукты банка',
      iconName: 'description',
      route: '/products/requests',
    ),
  ],
  applyProducts: const [
    DemoProduct(
      id: 'apply-halva',
      title: 'Халву',
      description: 'Карта рассрочки № 1',
      iconName: 'credit_card',
      route: '/products/halva',
    ),
    DemoProduct(
      id: 'apply-salary',
      title: 'Зарплатную карту',
      description: 'Быстро и просто',
      iconName: 'credit_card',
      route: '/forms/salary',
    ),
    DemoProduct(
      id: 'apply-card-account',
      title: 'Карту или счет',
      description: 'Для ежедневных расчетов',
      iconName: 'credit_card',
      route: '/cards',
    ),
    DemoProduct(
      id: 'apply-credit',
      title: 'Кредит',
      description: 'Мгновенное оформление',
      iconName: 'payments',
      route: '/forms/credit',
    ),
    DemoProduct(
      id: 'apply-deposit',
      title: 'Вклад',
      description: 'Сбережения онлайн',
      iconName: 'savings',
      route: '/products/deposits',
    ),
  ],
  moreItems: const [
    DemoMenuItem(
      id: 'menu-settings',
      title: 'Настройки',
      iconName: 'settings',
      route: '/settings',
    ),
    DemoMenuItem(
      id: 'menu-profile',
      title: 'Персональные данные',
      iconName: 'person',
      route: '/profile',
    ),
    DemoMenuItem(
      id: 'menu-documents',
      title: 'Документы',
      iconName: 'description',
      route: '/documents',
    ),
    DemoMenuItem(
      id: 'menu-notifications',
      title: 'Уведомления',
      iconName: 'notifications',
      route: '/notifications',
    ),
    DemoMenuItem(
      id: 'menu-currency',
      title: 'Курсы валют',
      iconName: 'currency_exchange',
      route: '/currency',
    ),
    DemoMenuItem(
      id: 'menu-loyalty',
      title: 'Манички. Вход в программу приятностей',
      iconName: 'loyalty',
      route: '/loyalty',
    ),
    DemoMenuItem(
      id: 'menu-exchange',
      title: 'Обменник Moby',
      iconName: 'swap_horiz',
      route: '/currency/exchange',
    ),
    DemoMenuItem(
      id: 'menu-branches',
      title: 'Банк на карте',
      iconName: 'location_on',
      route: '/branches',
    ),
    DemoMenuItem(
      id: 'menu-about',
      title: 'О Банке',
      iconName: 'info',
      route: '/about',
    ),
    DemoMenuItem(
      id: 'menu-safety',
      title: 'Ваша безопасность',
      iconName: 'security',
      route: '/safety',
    ),
  ],
);
