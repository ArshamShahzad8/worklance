import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/category.dart';
import '../models/freelancer.dart';
import '../models/job.dart';
import '../models/service.dart';
import '../models/user.dart';

/// All local/mock data for the WORKLANCE marketplace.
///
/// Keeping the data in one dedicated file (never inside widgets) means the
/// UI stays a pure consumer: swap this file for a real API later without
/// touching any screen.
abstract final class MockData {
  static const UserProfile currentUser = UserProfile(
    name: 'Aarsham Shahzad',
    email: 'aarsham@worklance.app',
    title: 'Client',
    location: 'Rawalpindi, Pakistan',
  );

  static final List<Category> categories = [
    const Category(
      id: 'c_web',
      name: 'Web Development',
      icon: Icons.code_rounded,
      description: 'Websites, web apps and APIs built to scale.',
    ),
    const Category(
      id: 'c_mobile',
      name: 'Mobile Development',
      icon: Icons.smartphone_rounded,
      description: 'Native and cross-platform mobile apps.',
    ),
    const Category(
      id: 'c_ux',
      name: 'UI/UX Design',
      icon: Icons.design_services_rounded,
      description: 'Interfaces people love to use.',
    ),
    const Category(
      id: 'c_graphic',
      name: 'Graphic Design',
      icon: Icons.palette_rounded,
      description: 'Logos, brand kits and visual identity.',
    ),
    const Category(
      id: 'c_marketing',
      name: 'Digital Marketing',
      icon: Icons.campaign_rounded,
      description: 'Grow your reach, leads and sales.',
    ),
    const Category(
      id: 'c_writing',
      name: 'Content Writing',
      icon: Icons.edit_note_rounded,
      description: 'Clear copy that converts readers to customers.',
    ),
    const Category(
      id: 'c_video',
      name: 'Video Editing',
      icon: Icons.videocam_rounded,
      description: 'Professional video production and editing.',
    ),
  ];

  static final List<Freelancer> freelancers = [
    Freelancer(
      id: 'f_rohan',
      name: 'Rohan Mehta',
      title: 'Full Stack Developer',
      avatarColor: AppColors.avatarPalette[0],
      rating: 4.9,
      reviewCount: 148,
      bio:
          'Full stack developer with 7 years of experience shipping SaaS products. '
          'I care about clean code, fast load times and honest communication.',
      skills: const ['JavaScript', 'React', 'Node.js', 'PostgreSQL'],
      location: 'Rawalpindi, Pakistan',
      memberSince: 'Member since 2021',
      completedJobs: 245,
    ),
    Freelancer(
      id: 'f_ayesha',
      name: 'Ayesha Khan',
      title: 'Flutter Developer',
      avatarColor: AppColors.avatarPalette[1],
      rating: 5.0,
      reviewCount: 96,
      bio:
          'Flutter specialist who has launched 30+ apps on both stores. '
          'From pixel-perfect UI to smooth animations and clean state management.',
      skills: const ['Flutter', 'Dart', 'REST APIs', 'UI Animation'],
      location: 'Lahore, Pakistan',
      memberSince: 'Member since 2022',
      completedJobs: 167,
    ),
    Freelancer(
      id: 'f_daniel',
      name: 'Daniel Costa',
      title: 'Product Designer',
      avatarColor: AppColors.avatarPalette[2],
      rating: 4.8,
      reviewCount: 213,
      bio:
          'Product designer focused on simple, human interfaces. '
          'I turn vague ideas into wireframes, prototypes and design systems.',
      skills: const ['Figma', 'Prototyping', 'Design Systems', 'Usability'],
      location: 'Lisbon, Portugal',
      memberSince: 'Member since 2020',
      completedJobs: 312,
    ),
    Freelancer(
      id: 'f_liam',
      name: 'Liam Patel',
      title: 'React Specialist',
      avatarColor: AppColors.avatarPalette[3],
      rating: 4.7,
      reviewCount: 82,
      bio:
          'Frontend engineer who loves building fast, accessible React apps. '
          'Next.js, TypeScript and Tailwind are my daily tools.',
      skills: const ['React', 'Next.js', 'TypeScript', 'Tailwind'],
      location: 'Dubai, UAE',
      memberSince: 'Member since 2022',
      completedJobs: 98,
    ),
    Freelancer(
      id: 'f_sofia',
      name: 'Sofia Rahman',
      title: 'Brand Designer',
      avatarColor: AppColors.avatarPalette[4],
      rating: 4.9,
      reviewCount: 176,
      bio:
          'Brand designer helping startups look credible from day one. '
          'I craft logos, color systems and guidelines that scale.',
      skills: const [
        'Logo Design',
        'Brand Strategy',
        'Illustrator',
        'Typography',
      ],
      location: 'Karachi, Pakistan',
      memberSince: 'Member since 2021',
      completedJobs: 234,
    ),
    Freelancer(
      id: 'f_marcus',
      name: 'Marcus Chen',
      title: 'Digital Marketer',
      avatarColor: AppColors.avatarPalette[5],
      rating: 4.6,
      reviewCount: 121,
      bio:
          'Performance marketer managing 6-figure ad budgets. '
          'I build content calendars and campaigns that actually convert.',
      skills: const ['Social Media', 'Meta Ads', 'Analytics', 'Copywriting'],
      location: 'Singapore',
      memberSince: 'Member since 2020',
      completedJobs: 189,
    ),
    Freelancer(
      id: 'f_priya',
      name: 'Priya Sharma',
      title: 'SEO Consultant',
      avatarColor: AppColors.avatarPalette[6],
      rating: 4.8,
      reviewCount: 104,
      bio:
          'SEO consultant who has taken 40+ sites to the first page of Google. '
          'Technical audits, keyword strategy and link building.',
      skills: const [
        'SEO',
        'Content Strategy',
        'Keyword Research',
        'Link Building',
      ],
      location: 'Islamabad, Pakistan',
      memberSince: 'Member since 2021',
      completedJobs: 156,
    ),
    Freelancer(
      id: 'f_emily',
      name: 'Emily Watson',
      title: 'Content Writer',
      avatarColor: AppColors.avatarPalette[7],
      rating: 4.9,
      reviewCount: 158,
      bio:
          'Writer for tech brands and SaaS companies. '
          'Blog posts, landing pages and guides that people actually finish.',
      skills: const ['Blog Writing', 'SEO Copy', 'Research', 'Editing'],
      location: 'London, UK',
      memberSince: 'Member since 2021',
      completedJobs: 223,
    ),
    Freelancer(
      id: 'f_omar',
      name: 'Omar Haddad',
      title: 'E-commerce Developer',
      avatarColor: AppColors.avatarPalette[0],
      rating: 4.7,
      reviewCount: 89,
      bio:
          'E-commerce developer who has built 60+ online stores. '
          'From product pages to checkout, payments and shipping integrations.',
      skills: const ['Shopify', 'WooCommerce', 'Payment Gateways', 'APIs'],
      location: 'Cairo, Egypt',
      memberSince: 'Member since 2022',
      completedJobs: 112,
    ),
    Freelancer(
      id: 'f_nina',
      name: 'Nina Petrova',
      title: 'Motion Designer',
      avatarColor: AppColors.avatarPalette[1],
      rating: 4.9,
      reviewCount: 132,
      bio:
          'Motion designer creating scroll-stopping visuals for social and ads. '
          'Explainer videos, product demos and branded animations.',
      skills: const [
        'Motion Graphics',
        'After Effects',
        'Video Editing',
        'Illustration',
      ],
      location: 'Istanbul, Turkey',
      memberSince: 'Member since 2020',
      completedJobs: 201,
    ),
  ];

  static final List<Service> services = [
    Service(
      id: 's_fullstack_web',
      title: 'Full Stack Web Development',
      description:
          'End-to-end web development — frontend, backend, database and deployment. '
          'Perfect for MVPs, dashboards and business websites.',
      category: categories[0],
      freelancer: freelancers[0],
      price: 350,
      deliveryDays: 14,
      skills: const ['React', 'Node.js', 'REST APIs', 'PostgreSQL'],
      featured: true,
    ),
    Service(
      id: 's_flutter_app',
      title: 'Flutter Mobile App Development',
      description:
          'Beautiful, high-performance mobile apps for iOS and Android from a single '
          'codebase, with smooth animations and clean architecture.',
      category: categories[1],
      freelancer: freelancers[1],
      price: 450,
      deliveryDays: 21,
      skills: const ['Flutter', 'Dart', 'REST APIs', 'UI Animation'],
      featured: true,
    ),
    Service(
      id: 's_uiux_design',
      title: 'UI/UX Design for Apps & Websites',
      description:
          'Research-driven UI/UX design: user flows, wireframes, high-fidelity mockups '
          'and a reusable design system tailored to your brand.',
      category: categories[2],
      freelancer: freelancers[2],
      price: 280,
      deliveryDays: 10,
      skills: const ['Figma', 'Wireframes', 'Prototyping', 'Design Systems'],
      featured: true,
    ),
    Service(
      id: 's_react_website',
      title: 'React Website Development',
      description:
          'Fast, accessible React and Next.js websites with SEO baked in. '
          'From marketing pages to complex interactive applications.',
      category: categories[0],
      freelancer: freelancers[3],
      price: 220,
      deliveryDays: 12,
      skills: const ['React', 'Next.js', 'TypeScript', 'Tailwind'],
    ),
    Service(
      id: 's_logo_brand',
      title: 'Logo & Brand Identity Design',
      description:
          'A complete visual identity: logo concepts, color palette, typography and '
          'a brand guidelines document you can hand to any team.',
      category: categories[3],
      freelancer: freelancers[4],
      price: 150,
      deliveryDays: 7,
      skills: const ['Logo Design', 'Brand Kit', 'Illustrator', 'Guidelines'],
      featured: true,
    ),
    Service(
      id: 's_social_media',
      title: 'Social Media Marketing & Management',
      description:
          'Full-service social media management: content calendar, platform-specific '
          'posts, community engagement and monthly performance reports.',
      category: categories[4],
      freelancer: freelancers[5],
      price: 190,
      deliveryDays: 30,
      skills: const ['Content Calendar', 'Meta Ads', 'Analytics'],
      featured: true,
    ),
    Service(
      id: 's_seo_services',
      title: 'SEO Services & Search Ranking',
      description:
          'Get found on Google. Technical SEO audit, on-page optimization, keyword '
          'strategy and quality link building to grow organic traffic.',
      category: categories[4],
      freelancer: freelancers[6],
      price: 260,
      deliveryDays: 21,
      skills: const ['SEO Audit', 'Keyword Research', 'Link Building'],
    ),
    Service(
      id: 's_content_writing',
      title: 'Content Writing & Blog Articles',
      description:
          'Research-backed blog posts, articles and landing page copy that rank and '
          'convert. Includes keyword optimization and editing.',
      category: categories[5],
      freelancer: freelancers[7],
      price: 80,
      deliveryDays: 5,
      skills: const ['Blog Writing', 'SEO Copy', 'Editing'],
    ),
    Service(
      id: 's_ecommerce_dev',
      title: 'E-commerce Website Development',
      description:
          'Launch a store that sells: product pages, secure checkout, payment gateway '
          'integration, shipping rules and inventory sync.',
      category: categories[0],
      freelancer: freelancers[8],
      price: 400,
      deliveryDays: 18,
      skills: const ['Shopify', 'Checkout', 'Integrations'],
    ),
    Service(
      id: 's_motion_graphics',
      title: 'Motion Graphics & Video Editing',
      description:
          'Scroll-stopping motion graphics, product demos and polished video edits '
          'with captions optimized for every social platform.',
      category: categories[6],
      freelancer: freelancers[9],
      price: 320,
      deliveryDays: 14,
      skills: const ['After Effects', 'Premiere', 'Motion Graphics'],
    ),
    Service(
      id: 's_email_marketing',
      title: 'Email Marketing Campaigns',
      description:
          'Convert subscribers into customers: campaign strategy, designed emails, '
          'automation flows and A/B testing with clear reporting.',
      category: categories[4],
      freelancer: freelancers[5],
      price: 140,
      deliveryDays: 10,
      skills: const ['Email Design', 'Automation', 'A/B Testing'],
    ),
    Service(
      id: 's_technical_writing',
      title: 'Technical Writing & Documentation',
      description:
          'Clear documentation for developers and users: API guides, product docs '
          'and tutorials written from scratch or cleaned up.',
      category: categories[5],
      freelancer: freelancers[7],
      price: 120,
      deliveryDays: 8,
      skills: const ['API Guides', 'Product Docs', 'Tutorials'],
    ),
    Service(
      id: 's_youtube_editing',
      title: 'YouTube Video Editing & Post-Production',
      description:
          'Professional YouTube video editing with color grading, sound design, '
          'transitions, thumbnails and platform-optimized exports.',
      category: categories[6],
      freelancer: freelancers[9],
      price: 200,
      deliveryDays: 7,
      skills: const ['Premiere Pro', 'DaVinci Resolve', 'Color Grading'],
      featured: true,
    ),
    Service(
      id: 's_graphic_design',
      title: 'Custom Graphic Design & Illustrations',
      description:
          'Eye-catching graphics for social media, presentations, ads and print. '
          'Custom illustrations and infographics included.',
      category: categories[3],
      freelancer: freelancers[4],
      price: 110,
      deliveryDays: 5,
      skills: const ['Illustrator', 'Photoshop', 'Infographics'],
    ),
    Service(
      id: 's_android_app',
      title: 'Android App Development (Kotlin)',
      description:
          'Native Android apps built with Kotlin, Jetpack Compose and modern '
          'architecture patterns for reliable, fast performance.',
      category: categories[1],
      freelancer: freelancers[0],
      price: 380,
      deliveryDays: 18,
      skills: const ['Kotlin', 'Jetpack Compose', 'Firebase', 'Material 3'],
    ),
    Service(
      id: 's_social_media_design',
      title: 'Social Media Content Design',
      description:
          'Scroll-stopping social media graphics, story templates and branded '
          'content packs for Instagram, TikTok and LinkedIn.',
      category: categories[3],
      freelancer: freelancers[4],
      price: 95,
      deliveryDays: 4,
      skills: const ['Canva', 'Figma', 'Social Media', 'Templates'],
    ),
  ];

  // --- Job marketplace clients ---
  static final List<JobClient> jobClients = [
    JobClient(
      id: 'jc_nova',
      name: 'Nova Fintech',
      avatarColor: AppColors.avatarPalette[2],
      rating: 4.8,
      reviewCount: 34,
      location: 'San Francisco, USA',
      jobsPosted: 12,
      totalSpent: 48500,
      paymentVerified: true,
      memberSince: 'Member since 2019',
    ),
    JobClient(
      id: 'jc_bloomwell',
      name: 'Bloomwell Health',
      avatarColor: AppColors.avatarPalette[4],
      rating: 4.6,
      reviewCount: 19,
      location: 'Toronto, Canada',
      jobsPosted: 7,
      totalSpent: 21300,
      paymentVerified: true,
      memberSince: 'Member since 2021',
    ),
    JobClient(
      id: 'jc_pixelforge',
      name: 'PixelForge Studio',
      avatarColor: AppColors.avatarPalette[5],
      rating: 4.9,
      reviewCount: 52,
      location: 'Berlin, Germany',
      jobsPosted: 21,
      totalSpent: 67200,
      paymentVerified: true,
      memberSince: 'Member since 2018',
    ),
    JobClient(
      id: 'jc_meridian',
      name: 'Meridian Realty Group',
      avatarColor: AppColors.avatarPalette[6],
      rating: 4.4,
      reviewCount: 11,
      location: 'Austin, USA',
      jobsPosted: 5,
      totalSpent: 9800,
      paymentVerified: false,
      memberSince: 'Member since 2023',
    ),
    JobClient(
      id: 'jc_trailblaze',
      name: 'TrailBlaze Fitness',
      avatarColor: AppColors.avatarPalette[1],
      rating: 4.7,
      reviewCount: 28,
      location: 'Sydney, Australia',
      jobsPosted: 9,
      totalSpent: 33750,
      paymentVerified: true,
      memberSince: 'Member since 2020',
    ),
    JobClient(
      id: 'jc_northwind',
      name: 'Northwind Logistics',
      avatarColor: AppColors.avatarPalette[0],
      rating: 4.5,
      reviewCount: 15,
      location: 'Rotterdam, Netherlands',
      jobsPosted: 6,
      totalSpent: 28900,
      paymentVerified: true,
      memberSince: 'Member since 2022',
    ),
    JobClient(
      id: 'jc_everline',
      name: 'Everline Media',
      avatarColor: AppColors.avatarPalette[3],
      rating: 4.9,
      reviewCount: 41,
      location: 'London, UK',
      jobsPosted: 18,
      totalSpent: 41200,
      paymentVerified: true,
      memberSince: 'Member since 2019',
    ),
    JobClient(
      id: 'jc_brightpath',
      name: 'Brightpath Learning',
      avatarColor: AppColors.avatarPalette[7],
      rating: 4.3,
      reviewCount: 8,
      location: 'Karachi, Pakistan',
      jobsPosted: 3,
      totalSpent: 4200,
      paymentVerified: false,
      memberSince: 'Member since 2024',
    ),
  ];

  static final List<Job> jobs = [
    Job(
      id: 'job_flutter_fintech',
      title: 'Flutter Developer for Mobile Banking App',
      description:
          'We are building a mobile-first banking app for underserved small '
          'businesses and need an experienced Flutter developer to join our '
          'core team. You will implement secure authentication, real-time '
          'transaction feeds, and a polished onboarding flow working closely '
          'with our design and backend teams. Clean architecture and test '
          'coverage matter to us — this is a long-term engagement with a '
          'small, senior team.',
      category: categories[1],
      skills: const ['Flutter', 'Dart', 'REST APIs', 'State Management'],
      budgetType: BudgetType.fixed,
      budgetMin: 2500,
      budgetMax: 4000,
      experienceLevel: ExperienceLevel.expert,
      duration: '3 to 6 months',
      postedAt: DateTime.now().subtract(const Duration(hours: 6)),
      proposalsCount: 8,
      client: jobClients[0],
      location: 'Remote',
      featured: true,
    ),
    Job(
      id: 'job_react_dashboard',
      title: 'React Developer for SaaS Analytics Dashboard',
      description:
          'Our analytics platform needs a skilled React developer to build '
          'out a new dashboard module — interactive charts, filterable data '
          'tables, and a saved-views feature. You will work from Figma '
          'designs and an existing design system, integrating with a REST '
          'API our backend team maintains. Experience with data-heavy UIs '
          'is a big plus.',
      category: categories[0],
      skills: const ['React', 'TypeScript', 'Data Visualization', 'REST APIs'],
      budgetType: BudgetType.hourly,
      budgetMin: 25,
      budgetMax: 45,
      experienceLevel: ExperienceLevel.intermediate,
      duration: '1 to 3 months',
      postedAt: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      proposalsCount: 23,
      client: jobClients[2],
      location: 'Remote',
      featured: true,
    ),
    Job(
      id: 'job_uiux_wellness',
      title: 'UI/UX Designer for Wellness App Redesign',
      description:
          'We are redesigning our meditation and wellness app to feel calmer '
          'and more intuitive. Looking for a designer who can lead user '
          'research, produce wireframes and high-fidelity mockups in Figma, '
          'and hand off a clean, reusable design system to our dev team. '
          'Portfolio with wellness, health or lifestyle apps preferred.',
      category: categories[2],
      skills: const ['Figma', 'User Research', 'Design Systems', 'Prototyping'],
      budgetType: BudgetType.fixed,
      budgetMin: 1800,
      budgetMax: 2600,
      experienceLevel: ExperienceLevel.intermediate,
      duration: '1 to 3 months',
      postedAt: DateTime.now().subtract(const Duration(days: 2)),
      proposalsCount: 16,
      client: jobClients[1],
      location: 'Remote',
    ),
    Job(
      id: 'job_graphic_identity',
      title: 'Graphic Designer for Full Brand Identity',
      description:
          'A new boutique real estate brand needs a complete visual '
          'identity: logo, color palette, typography system, business cards '
          'and a short brand guidelines PDF. We have a rough moodboard ready '
          'to share. Looking for someone who can turn that into a polished, '
          'professional identity within a few weeks.',
      category: categories[3],
      skills: const ['Logo Design', 'Brand Identity', 'Illustrator', 'Typography'],
      budgetType: BudgetType.fixed,
      budgetMin: 600,
      budgetMax: 900,
      experienceLevel: ExperienceLevel.intermediate,
      duration: 'Less than 1 month',
      postedAt: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
      proposalsCount: 31,
      client: jobClients[3],
      location: 'Remote',
    ),
    Job(
      id: 'job_fullstack_marketplace',
      title: 'Full Stack Developer for B2B Marketplace Platform',
      description:
          'We are launching a B2B marketplace connecting wholesale buyers '
          'and suppliers, and need a full stack developer to help build core '
          'features: vendor onboarding, order management, and an admin '
          'panel. Our stack is Node.js on the backend with a React frontend '
          'and PostgreSQL. This is a foundational role on a small founding '
          'team.',
      category: categories[0],
      skills: const ['Node.js', 'React', 'PostgreSQL', 'REST APIs'],
      budgetType: BudgetType.fixed,
      budgetMin: 3500,
      budgetMax: 6000,
      experienceLevel: ExperienceLevel.expert,
      duration: '3 to 6 months',
      postedAt: DateTime.now().subtract(const Duration(days: 4)),
      proposalsCount: 12,
      client: jobClients[2],
      location: 'Remote',
      featured: true,
    ),
    Job(
      id: 'job_backend_logistics',
      title: 'Backend Developer for Shipment Tracking API',
      description:
          'Our logistics platform needs a backend developer to design and '
          'build a shipment tracking API: webhook ingestion from carrier '
          'partners, a normalized events model, and rate-limited public '
          'endpoints for partner integrations. Experience with high-volume '
          'APIs and queue-based processing is important.',
      category: categories[0],
      skills: const ['Node.js', 'PostgreSQL', 'Redis', 'API Design'],
      budgetType: BudgetType.hourly,
      budgetMin: 30,
      budgetMax: 55,
      experienceLevel: ExperienceLevel.expert,
      duration: '3 to 6 months',
      postedAt: DateTime.now().subtract(const Duration(days: 5, hours: 8)),
      proposalsCount: 9,
      client: jobClients[5],
      location: 'Remote',
    ),
    Job(
      id: 'job_wordpress_realestate',
      title: 'WordPress Developer for Real Estate Listings Site',
      description:
          'We need a WordPress developer to build a property listings site '
          'with search/filter by price, location and property type, an '
          'agent directory, and a lead-capture contact form. We have brand '
          'assets and copy ready. Please share examples of real estate or '
          'listing-style WordPress sites you have built.',
      category: categories[0],
      skills: const ['WordPress', 'PHP', 'Custom Themes', 'ACF'],
      budgetType: BudgetType.fixed,
      budgetMin: 900,
      budgetMax: 1400,
      experienceLevel: ExperienceLevel.intermediate,
      duration: '1 to 3 months',
      postedAt: DateTime.now().subtract(const Duration(days: 6)),
      proposalsCount: 27,
      client: jobClients[3],
      location: 'Remote',
    ),
    Job(
      id: 'job_mobile_fitness',
      title: 'Mobile App Developer for Fitness Tracking App',
      description:
          'TrailBlaze Fitness is building a companion app for our wearable '
          'devices — workout logging, step and heart-rate tracking, and '
          'social challenges between friends. Looking for a cross-platform '
          'mobile developer (Flutter or React Native) to build the MVP '
          'alongside our in-house designer.',
      category: categories[1],
      skills: const ['Flutter', 'Firebase', 'Health APIs', 'Push Notifications'],
      budgetType: BudgetType.fixed,
      budgetMin: 4000,
      budgetMax: 7000,
      experienceLevel: ExperienceLevel.expert,
      duration: 'More than 6 months',
      postedAt: DateTime.now().subtract(const Duration(days: 7, hours: 2)),
      proposalsCount: 14,
      client: jobClients[4],
      location: 'Remote',
      featured: true,
    ),
    Job(
      id: 'job_content_saas',
      title: 'Content Writer for SaaS Blog & Guides',
      description:
          'We publish two in-depth articles a week on our analytics SaaS '
          'blog and need a reliable writer who understands B2B software. '
          'Topics range from product tutorials to industry trend pieces. '
          'We will provide an outline and internal data; you bring clear, '
          'well-researched writing and a solid grasp of SEO basics.',
      category: categories[5],
      skills: const ['Blog Writing', 'SEO', 'B2B SaaS', 'Research'],
      budgetType: BudgetType.hourly,
      budgetMin: 18,
      budgetMax: 32,
      experienceLevel: ExperienceLevel.intermediate,
      duration: 'More than 6 months',
      postedAt: DateTime.now().subtract(const Duration(days: 8)),
      proposalsCount: 38,
      client: jobClients[2],
      location: 'Remote',
    ),
    Job(
      id: 'job_video_youtube',
      title: 'Video Editor for Weekly YouTube Channel',
      description:
          "Everline Media runs a weekly interview-style YouTube channel and "
          'needs a dependable video editor for ongoing episodes: rough cut, '
          'pacing, captions, sound leveling, and a short highlight clip for '
          'social. Raw footage runs 45-60 minutes per episode. Send a link '
          'to edited work similar in style if you have it.',
      category: categories[6],
      skills: const ['Premiere Pro', 'Captions', 'Sound Design', 'Color Grading'],
      budgetType: BudgetType.fixed,
      budgetMin: 150,
      budgetMax: 250,
      experienceLevel: ExperienceLevel.intermediate,
      duration: 'More than 6 months',
      postedAt: DateTime.now().subtract(const Duration(days: 9, hours: 10)),
      proposalsCount: 22,
      client: jobClients[6],
      location: 'Remote',
    ),
    Job(
      id: 'job_flutter_ecommerce',
      title: 'Flutter Developer for E-commerce Storefront App',
      description:
          'We are extending our web store into a native mobile app with '
          'Flutter: product browsing, cart, checkout via Stripe, and push '
          'notifications for order updates. Backend REST API already '
          'exists and is documented. Looking for someone who can move fast '
          'without cutting corners on UI polish.',
      category: categories[1],
      skills: const ['Flutter', 'Stripe', 'REST APIs', 'State Management'],
      budgetType: BudgetType.fixed,
      budgetMin: 1600,
      budgetMax: 2400,
      experienceLevel: ExperienceLevel.intermediate,
      duration: '1 to 3 months',
      postedAt: DateTime.now().subtract(const Duration(days: 11)),
      proposalsCount: 19,
      client: jobClients[6],
      location: 'Remote',
    ),
    Job(
      id: 'job_uiux_onboarding',
      title: 'UI/UX Designer for App Onboarding Flow',
      description:
          'Small but focused project: we need 4-5 onboarding screens '
          'redesigned for our learning app to improve first-time user '
          'activation. Deliverables are Figma mockups plus a short '
          'interaction-notes doc for developers. Great first project if '
          "you're newer to app design and want a fast, well-scoped gig.",
      category: categories[2],
      skills: const ['Figma', 'Mobile UI', 'Onboarding', 'Wireframing'],
      budgetType: BudgetType.fixed,
      budgetMin: 250,
      budgetMax: 400,
      experienceLevel: ExperienceLevel.entry,
      duration: 'Less than 1 month',
      postedAt: DateTime.now().subtract(const Duration(hours: 20)),
      proposalsCount: 3,
      client: jobClients[7],
      location: 'Remote',
    ),
  ];
}
