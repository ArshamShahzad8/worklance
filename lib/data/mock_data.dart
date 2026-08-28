import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/category.dart';
import '../models/freelancer.dart';
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
}
