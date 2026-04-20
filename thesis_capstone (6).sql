-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Feb 07, 2026 at 01:41 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `thesis_capstone`
--

-- --------------------------------------------------------

--
-- Table structure for table `businesses`
--

CREATE TABLE `businesses` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `business_name` varchar(255) NOT NULL,
  `owner_name` varchar(255) NOT NULL,
  `address` varchar(255) NOT NULL,
  `contact_number` varchar(20) NOT NULL,
  `category` enum('plumbing','siphoning','both') NOT NULL,
  `business_type` enum('Individual','Small Business','Company') NOT NULL DEFAULT 'Individual',
  `bir_registration` varchar(255) DEFAULT NULL,
  `dti_registration` varchar(255) DEFAULT NULL,
  `mayor_permit` varchar(255) DEFAULT NULL,
  `business_permit` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `businesses`
--

INSERT INTO `businesses` (`id`, `user_id`, `business_name`, `owner_name`, `address`, `contact_number`, `category`, `business_type`, `bir_registration`, `dti_registration`, `mayor_permit`, `business_permit`, `created_at`, `updated_at`) VALUES
(3, 48, 'Cillum cupiditate es', 'Accusantium eiusmod', 'Blanditiis dolor id', 'Id qui est ipsum cu', 'both', 'Individual', NULL, NULL, NULL, NULL, '2026-01-17 02:21:52', '2026-01-17 02:21:52'),
(48, 232, 'Eaque odit itaque no', 'In blanditiis archit', 'Consequatur Maiores', 'Et possimus volupta', 'plumbing', 'Small Business', NULL, NULL, NULL, NULL, '2026-01-23 23:36:19', '2026-01-23 23:36:19'),
(69, 260, 'sa', 'sa', 'sa', '2121212121', 'plumbing', 'Small Business', 'business_docs/Uc8LrO1PJ59KPQNuAqqQUrDEKmRIww8UCd6D9VlX.pdf', 'business_docs/wF78HW95G6BlBqcofwROs9fMUQWl7A8h3rlIxNt4.pdf', 'business_docs/xmuGn8BqfbY1lvZNIO5qDUvAN85T2GtkdDFDxitQ.pdf', 'business_docs/jzVGMQMBQDdNcKGC7g5FeMgQQObuLY0l2T6nGHzm.pdf', '2026-01-25 14:04:20', '2026-01-25 14:04:20'),
(77, 274, 'aasa', 'sassas', 'saas', '1212121', 'plumbing', 'Small Business', 'business_docs/rbmz29XH4SZjOUEG1PByudaHjMakkPRP8x2qWLnT.pdf', 'business_docs/YMYMkTHhyxFzCBmGaWeQ4BoHGA6o10gW1I9xGJ0u.pdf', 'business_docs/gzp2TGVIrD6to4RelwReAKzYvkGFMDX4nCITKr6w.pdf', 'business_docs/mv6YIod7dRmwg0fEA9x8Bbp3PVGS52goKxW9WU4m.pdf', '2026-01-26 17:04:20', '2026-01-26 17:04:20'),
(78, 275, 'sasa', 'saasa', 'sas', '1212121', 'plumbing', 'Small Business', 'business_docs/vwFBwXHVxWRiFQNWjPmrfDu18NBj4qoyfFztCXCK.pdf', 'business_docs/Fu04CJdW7UZ7befB1pJ6ZgRpAc1eFRER5ZLZpbZf.pdf', 'business_docs/lcRi3J9fZl6qzh0KsyBBLgFLCZWM83uTpHqhiD6v.pdf', 'business_docs/UM0Y8Mcnv42ylvmWyDuQBVqSvUtjDUe8i4LlN2K1.pdf', '2026-01-26 22:32:40', '2026-01-26 22:32:40'),
(79, 276, 'sas', 'sa', 'asa', '111111', 'plumbing', 'Company', 'business_docs/65SxtUQEiAQkCnfXWK5Ug8K1qK2Ld489zOknI2co.pdf', 'business_docs/CTpLnteW806JcmjT0zVumiTxyLRB7Nr4PhOTmhYg.pdf', 'business_docs/xIZ0xHJ0Vi9FZc21jBs5Ui4Hjvf9AlVv2tw9JRd7.pdf', 'business_docs/LGMkYIbrjMzFsNWSveqPQfyiOiNKZZLAPT8HxSTM.pdf', '2026-01-27 01:30:49', '2026-01-27 01:30:49'),
(83, 289, 'sasa', 'sa', 'sa', '12121212', 'plumbing', 'Small Business', 'business_docs/KsIS7rVRlYSmd1NDOBcEkhmILa1lWVtqwxGpEr4J.pdf', 'business_docs/YNjyE6RFuDlQl0Q7lxD6HphXFhcEWSsJB1xVhWby.pdf', 'business_docs/mZSadqdxhunMfGz0XW6oLrlZv2nyvxuJbRDNFX8l.pdf', 'business_docs/fiI2K3NoppO5BpjwO0IFExgWDMZKAcY3wPEIucbF.pdf', '2026-01-27 13:38:21', '2026-01-27 13:38:21'),
(84, 292, 'sa', 'sas', 'asa', '12121212', 'plumbing', 'Company', 'business_docs/kUORqHCjAL1Ux7jFOF6ehx0W5FJeVkY1dv58tDGf.pdf', 'business_docs/l9iVvmIAEbIsFu4LoDiWCFB8MdFgwGtPSs3nvOOt.pdf', 'business_docs/AYsCfHeL4tVCyIb1BjL5jaqOBeftQ1se018wvjdE.pdf', 'business_docs/EDQMqMRJ7gBFGpJiryT1wpTkoqC1YScpcTfDKski.pdf', '2026-01-31 00:03:38', '2026-01-31 00:03:38'),
(86, 295, 'sa', 'sa', 'sa', '1212121', 'siphoning', 'Small Business', 'business_docs/KVhJvDbnS5nSOSKyS7EkZcv1v1MGjwxGu5oidTPd.pdf', 'business_docs/6vU0ksJgv3FEeWoGVnuckyTZr5PubVLoPI4iq5gZ.pdf', 'business_docs/qIHbT2rskKxQ8RrwdxHBDN8hDp2DKJ9GcMvEakaa.pdf', 'business_docs/hz3vEDW4LQ0ajEGOcfV0IfayVlkcZoiFTmLVFnYX.pdf', '2026-02-01 23:39:08', '2026-02-01 23:39:08'),
(94, 310, 'sasa', 'sa', 'sa', '12121212', 'plumbing', 'Company', 'business_docs/y1HzHly4V891DcRbsEnWNB3pvz0sIb8gFm8lWH12.pdf', 'business_docs/e0i7seVmgKc1aU8RDngwcPLWrQKj2d6ZG6GGre9i.pdf', 'business_docs/mkecoD215GM6fnJxedkrZxbeVj8E9rrT8tba0ssY.pdf', 'business_docs/XRiAR3nYPSZtgNsr6F4HAmtOX0AVnFLY1JvCyUMA.pdf', '2026-02-05 22:41:41', '2026-02-05 22:41:41'),
(95, 312, 'sas', 'sa', 'sa', '12121212', 'plumbing', 'Company', 'business_docs/7Bc9HdwrkTtlAlnHwJSjkBEkwYMNzYlLFERrzkvG.pdf', 'business_docs/M3H87A5nRKqpOcCKjGT2AB5fwiWa3srHHw8HnaDS.pdf', 'business_docs/P9BbLoYWB6dZt6fIAEQ5x7Q1nR9dE9caPly8zuWV.pdf', 'business_docs/XWLKsQnOLe7ZBfX4nzHGAb0UK9bRBOENnHHSkijr.pdf', '2026-02-06 23:08:24', '2026-02-06 23:08:24'),
(96, 313, 'sa', 'sa', 'sa', '121212', 'siphoning', 'Company', 'business_docs/VfW5c3jbrFS7JPT7EHD0qVgISzpTuUZlxQUVwxxQ.pdf', 'business_docs/q6f7Brs51Jsulghi7KtQ0myacs3B2DKnoxRDZCxZ.pdf', 'business_docs/KAWLsB3Ys5KxWKM5VdJ6zrcfiCzupQGX4PTgqBE4.pdf', 'business_docs/1nMieymgYJ78wv3gXIdjT7Qmnq7IkfTXJuAYdJkV.pdf', '2026-02-06 23:09:40', '2026-02-06 23:09:40'),
(97, 314, 'sas', 'sa', 'sa', '1212121', 'both', 'Company', 'business_docs/DBQSlgVikxePNC0WuOcWxgnU8CIJSDBmmIKQ6AkV.pdf', 'business_docs/Y3q7y579uOoHyKKr08TQpxh2lrxo8ZD2X7bozlGl.pdf', 'business_docs/eYbWXrgcpVWz32Bz4Sj8hPd6TfgfDZVyhxRoMBmz.pdf', 'business_docs/5pMwFYWJYPl5Y3bFgERPXI1qqiDCspzWl977t2lK.pdf', '2026-02-07 01:48:21', '2026-02-07 01:48:21');

-- --------------------------------------------------------

--
-- Table structure for table `business_permits`
--

CREATE TABLE `business_permits` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `company_name` varchar(255) NOT NULL,
  `owner_name` varchar(255) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `failed_jobs`
--

CREATE TABLE `failed_jobs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `uuid` varchar(255) NOT NULL,
  `connection` text NOT NULL,
  `queue` text NOT NULL,
  `payload` longtext NOT NULL,
  `exception` longtext NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `migrations`
--

CREATE TABLE `migrations` (
  `id` int(10) UNSIGNED NOT NULL,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `migrations`
--

INSERT INTO `migrations` (`id`, `migration`, `batch`) VALUES
(1, '2014_10_12_000000_create_users_table', 1),
(2, '2014_10_12_100000_create_password_resets_table', 1),
(3, '2019_08_19_000000_create_failed_jobs_table', 1),
(4, '2019_12_14_000001_create_personal_access_tokens_table', 1),
(5, '2026_01_09_064551_add_role_to_users_table', 1),
(6, '2026_01_09_064802_create_business_permits_table', 2),
(7, '2026_01_09_073701_add_role_to_users_table', 3),
(9, '2026_01_12_150626_create_permits_table', 4),
(10, '2026_01_15_164006_add_role_and_approval_to_users_table', 5),
(11, '2026_01_15_170429_create_businesses_table', 6),
(12, '2026_01_15_170448_create_service_providers_table', 6),
(13, '2026_01_16_044125_update_role_enum_on_users_table', 7),
(14, '2026_01_16_080403_add_columns_to_service_providers_table', 8),
(15, '2026_01_16_084835_create_businesses_table', 9),
(16, '2026_01_17_040226_add_approved_to_businesses_table', 9),
(17, '2026_01_17_044142_create_reviews_table', 10),
(18, '2026_01_18_042745_add_name_fields_to_users_table', 11),
(19, '2026_01_18_044430_drop_name_column_from_users_table', 12),
(20, '2026_01_19_072556_add_location_to_service_providers_table', 13),
(21, '2026_01_19_074820_create_work_histories_table', 14),
(22, '2026_01_19_075017_add_is_available_to_service_providers_table', 15),
(23, '2026_01_19_080431_add_is_approved_to_service_providers_table', 16),
(24, '2026_01_20_024216_create_service_requests_table', 17),
(25, '2026_01_20_040037_add_latitude_longitude_to_users_table', 18),
(26, '2026_01_23_084141_add_business_type_to_businesses_table', 19),
(27, '2026_01_24_041531_add_business_id_to_service_requests_table', 20),
(28, '2026_01_26_091206_add_rejection_reason_to_users_table', 21),
(29, '2026_01_26_091629_add_status_to_users_table', 22),
(30, '2026_01_26_091829_add_rejection_reason_to_users_table', 23),
(31, '2026_01_26_161758_make_service_provider_nullable_on_service_requests', 24),
(32, '2026_01_27_030808_make_contact_number_nullable_on_users_table', 25),
(33, '2026_01_31_161702_add_reject_reason_to_service_providers_table', 26),
(34, '2026_01_31_170551_remove_reject_reason_from_service_providers_table', 27),
(35, '2026_01_31_170701_add_is_rejected_to_service_providers_table', 28),
(36, '2026_02_01_083144_create_service_provider_applications_table', 29),
(37, '2026_02_02_080403_add_status_to_service_providers', 30),
(38, '2026_02_05_171710_add_accepted_status_to_service_requests_table', 31),
(39, '2026_02_05_173516_update_status_enum_in_service_requests_table', 32),
(40, '2026_02_05_174638_add_materials_needed_to_service_requests_table', 33),
(41, '2026_02_06_143402_create_request_materials_table', 34),
(42, '2026_02_06_145926_create_service_material_templates_table', 35),
(43, '2026_02_06_165451_update_service_requests_status_and_rejection', 36),
(44, '2026_02_06_170442_create_service_request_proofs_table', 37);

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `password_resets`
--

INSERT INTO `password_resets` (`email`, `token`, `created_at`) VALUES
('admin@thesis.com', '$2y$10$ZiyergH.FFJwoDe7MbZHOOlN6EyB2APW5610NKJ2knhyDpWfHwoJu', '2026-01-09 15:07:09');

-- --------------------------------------------------------

--
-- Table structure for table `permits`
--

CREATE TABLE `permits` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `business_name` varchar(255) NOT NULL,
  `owner_name` varchar(255) NOT NULL,
  `permit_number` varchar(255) NOT NULL,
  `business_type` varchar(255) DEFAULT NULL,
  `status` enum('Pending','Approved','Rejected','Suspended','Expired') NOT NULL DEFAULT 'Pending',
  `file` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `personal_access_tokens`
--

CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `request_materials`
--

CREATE TABLE `request_materials` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `service_request_id` bigint(20) UNSIGNED NOT NULL,
  `material_name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL,
  `unit` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `reviews`
--

CREATE TABLE `reviews` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `service_provider_id` bigint(20) UNSIGNED NOT NULL,
  `rating` tinyint(4) NOT NULL,
  `review` text DEFAULT NULL,
  `anonymous` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `reviews`
--

INSERT INTO `reviews` (`id`, `user_id`, `service_provider_id`, `rating`, `review`, `anonymous`, `created_at`, `updated_at`) VALUES
(1, 17, 1, 5, 'sa', 0, '2026-01-17 12:59:33', '2026-01-17 12:59:33'),
(2, 17, 1, 2, 'sas', 1, '2026-01-17 13:50:19', '2026-01-17 13:50:19'),
(4, 17, 27, 5, 'sasa', 0, '2026-01-19 23:55:53', '2026-01-19 23:55:53');

-- --------------------------------------------------------

--
-- Table structure for table `service_material_templates`
--

CREATE TABLE `service_material_templates` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `service_type` varchar(255) NOT NULL,
  `material_name` varchar(255) NOT NULL,
  `default_qty` int(11) NOT NULL,
  `unit` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `service_providers`
--

CREATE TABLE `service_providers` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `business_id` bigint(20) UNSIGNED NOT NULL,
  `category` enum('plumbing','siphoning','both') NOT NULL,
  `service_description` text NOT NULL,
  `experience_years` int(11) NOT NULL,
  `valid_id` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `is_approved` tinyint(1) NOT NULL DEFAULT 0,
  `is_rejected` tinyint(1) NOT NULL DEFAULT 0,
  `reject_reason` text DEFAULT NULL,
  `is_available` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `service_providers`
--

INSERT INTO `service_providers` (`id`, `user_id`, `business_id`, `category`, `service_description`, `experience_years`, `valid_id`, `latitude`, `longitude`, `is_approved`, `is_rejected`, `reject_reason`, `is_available`, `created_at`, `updated_at`, `status`) VALUES
(1, 33, 0, 'plumbing', 'Please update your description', 0, NULL, NULL, NULL, 0, 0, NULL, 1, '2026-01-17 01:23:02', '2026-01-20 01:59:04', 'pending'),
(27, 101, 0, 'plumbing', 'sa', 1, NULL, 14.3100000, 120.9600000, 0, 0, NULL, 1, '2026-01-19 23:27:38', '2026-01-20 13:44:40', 'pending'),
(35, 134, 0, 'both', 'Aperiam voluptatem o', 5, NULL, 14.3100000, 120.9600000, 0, 0, NULL, 0, '2026-01-20 02:52:53', '2026-01-20 02:52:53', 'pending'),
(104, 298, 84, 'siphoning', 'sasa', 11, NULL, 14.3300000, 120.9500000, 1, 0, NULL, 1, '2026-02-02 17:44:38', '2026-02-06 23:12:43', 'pending');

-- --------------------------------------------------------

--
-- Table structure for table `service_provider_applications`
--

CREATE TABLE `service_provider_applications` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `category` varchar(255) NOT NULL,
  `service_description` text DEFAULT NULL,
  `experience_years` int(11) NOT NULL DEFAULT 0,
  `status` enum('pending','approved','rejected') NOT NULL DEFAULT 'pending',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `service_requests`
--

CREATE TABLE `service_requests` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `user_id` bigint(20) UNSIGNED NOT NULL,
  `business_id` bigint(20) UNSIGNED NOT NULL,
  `service_provider_id` bigint(20) UNSIGNED DEFAULT NULL,
  `service_type` varchar(255) DEFAULT NULL,
  `latitude` decimal(10,7) NOT NULL,
  `longitude` decimal(10,7) NOT NULL,
  `address_text` varchar(255) DEFAULT NULL,
  `preferred_date` date DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `materials_needed` text DEFAULT NULL,
  `status` varchar(255) DEFAULT 'pending',
  `rejection_reason` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `service_requests`
--

INSERT INTO `service_requests` (`id`, `user_id`, `business_id`, `service_provider_id`, `service_type`, `latitude`, `longitude`, `address_text`, `preferred_date`, `notes`, `materials_needed`, `status`, `rejection_reason`, `created_at`, `updated_at`) VALUES
(7, 17, 0, 27, 'plumbing', 14.3100000, 120.9600000, 'sasasas', '2026-01-20', 'Please read the terms carefully', NULL, 'rejected', NULL, '2026-01-20 13:13:43', '2026-01-20 13:24:05'),
(13, 17, 0, 27, 'plumbing', 14.3100000, 120.9600000, 'sasasa', '2026-01-16', NULL, NULL, 'pending', NULL, '2026-01-20 13:59:26', '2026-01-20 13:59:26'),
(14, 17, 0, 27, 'plumbing', 14.3100000, 120.9600000, 'sasas', '2026-01-14', 'Please read the terms carefully', NULL, 'pending', NULL, '2026-01-20 14:02:24', '2026-01-20 14:02:24'),
(55, 299, 94, NULL, 'plumbing', 14.3300000, 120.9500000, 'sas', '2026-02-12', 'asasa', NULL, 'pending', NULL, '2026-02-06 22:47:01', '2026-02-06 22:47:01'),
(56, 299, 94, NULL, 'plumbing', 14.3300000, 120.9500000, 'sas', '2026-02-26', 'asasa', NULL, 'pending', NULL, '2026-02-06 22:51:29', '2026-02-06 22:51:29'),
(57, 299, 84, 104, 'plumbing', 14.3300000, 120.9500000, 'asa', '2026-02-06', 'sas', NULL, 'awaiting_material', NULL, '2026-02-06 22:52:04', '2026-02-06 22:53:16'),
(58, 299, 96, 104, 'siphoning', 14.3300000, 120.9500000, 'sa', '2026-02-24', 'sasa', '[\"sasasa\"]', 'in_progress', NULL, '2026-02-06 23:11:02', '2026-02-07 00:59:24');

-- --------------------------------------------------------

--
-- Table structure for table `service_request_proofs`
--

CREATE TABLE `service_request_proofs` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `service_request_id` bigint(20) UNSIGNED NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `middle_initial` char(1) DEFAULT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `is_approved` tinyint(1) NOT NULL DEFAULT 0,
  `role` varchar(50) NOT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'pending',
  `rejection_reason` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `first_name`, `middle_initial`, `last_name`, `email`, `latitude`, `longitude`, `contact_number`, `email_verified_at`, `password`, `remember_token`, `created_at`, `updated_at`, `is_approved`, `role`, `status`, `rejection_reason`) VALUES
(1, 'Admin', NULL, 'User', 'admin@thesis.com', NULL, NULL, '', NULL, '$2y$10$poFx7wVFXSoPm4CLLYac0uECdZh55tWKqwWo30UjcWuYnEmnWWbTq', 'vAqROu1WpXbDoOCLDDK0UjWZJepq2pOyn9CBVqUCGlLpbwk5vtFvu0XI82pA', '2026-01-09 14:46:47', '2026-01-09 14:46:47', 1, 'admin', 'approved', NULL),
(315, 'Admin', NULL, 'Local', 'admin@thesis.local', NULL, NULL, '', NULL, '$2y$10$VCVA.d4aIMywmrWvGYIThe8Fu9JSzzilJt.uxxW4GcJIFeElbIFyK', NULL, '2026-04-09 00:00:00', '2026-04-09 00:00:00', 1, 'admin', 'approved', NULL),
(17, '', NULL, '', 'steve1@gmail.com', NULL, NULL, '', NULL, '$2y$10$6fQ8P.oNXfZ60p8Ri8RGq.F658yJxMYxvaPdP5TElB/GOJ1/75V82', NULL, '2026-01-16 01:49:54', '2026-01-16 01:50:59', 1, 'user', 'pending', NULL),
(22, '', NULL, '', 'pro@gmail.com', NULL, NULL, '', NULL, '$2y$10$rc21BRFJGiFBRmqzXmLk0OOZW4Fl2EH/FxoMk6PtFF7z5qL9pO7he', NULL, '2026-01-16 14:40:54', '2026-01-16 14:40:54', 1, 'procurement', 'pending', NULL),
(26, '', NULL, '', 'steve@gmail.com', NULL, NULL, '', NULL, '$2y$10$8yoETjfsrrqLfV1mYTN3buzURSqHZPLGRUF3ejyzAfEYw1ZG7xf7W', NULL, '2026-01-16 15:14:47', '2026-01-16 15:14:47', 1, 'admin', 'pending', NULL),
(33, '', NULL, '', 'tetyza@mailinator.com', NULL, NULL, '', NULL, '$2y$10$ch1EKWDt2TRDsCSVXBfZ6O7bbIIZZpRZi88FybxQaNpoMfRKr0u/W', NULL, '2026-01-16 15:46:34', '2026-01-19 16:26:59', 1, 'serviceprovider', 'pending', NULL),
(37, '', NULL, '', 'fn@gmail.com', NULL, NULL, '', NULL, '$2y$10$gQGsd0alsMSJ4NsXddn21unrg5gMogMAeZ.Xse/cEK..5wZ6zq3j2', NULL, '2026-01-16 16:33:19', '2026-01-16 16:33:19', 1, 'finance', 'pending', NULL),
(50, '', NULL, '', 'hr@gmail.com', NULL, NULL, '', NULL, '$2y$10$8G8knvAvhnC0trClxFv/IeEsCM85CnYwO0m2VWCuTSHouWC9iT88a', NULL, '2026-01-17 11:20:41', '2026-01-17 11:20:41', 1, 'hr', 'pending', NULL),
(197, 'Doloribus aut volupt', 'E', 'Nemo dolores ipsum a', 'tev@mailinator.com', 14.3100000, 120.9600000, 'Pariatur Obcaecati', NULL, '$2y$10$w/dwHvU1.dUT6egQR7ekMeMdPy9AaoGY3B5afvEuBA20QTNFGH1f6', NULL, '2026-01-22 00:17:16', '2026-01-22 00:17:16', 1, 'user', 'pending', NULL),
(232, 'Business', NULL, 'Account', 'tedewybu@mailinator.com', 14.3300000, 120.9400000, 'Et possimus volupta', NULL, '$2y$10$CM3RMB8e7GUqGahZgnDrauDbJv6kFByTg563YQM6SaLzizFVs72c2', NULL, '2026-01-23 23:36:19', '2026-01-23 23:37:13', 1, 'business', 'pending', NULL),
(236, '1 assumenda dolore', 'e', 'Quis ut ea voluptas', 'befud@mailinator.com', 14.3300000, 120.9400000, 'Voluptas obcaecati t', NULL, '$2y$10$pzx0W1/k361K.79zvW1YC.7F/JKwqE7r/M8.DlDpjehOwvvqfyspW', NULL, '2026-01-24 02:55:24', '2026-01-24 03:16:45', 1, 'user', 'pending', NULL),
(240, 'Sed voluptatem paria', 'E', 'Deserunt cupidatat d', 'dureza@mailinator.com', 14.3300000, 120.9400000, 'Tenetur quas ea corr', NULL, '$2y$10$ke0CWpFKI5gxjXoXFct2w.P4OH2iQ40nxcYjIOSa9H2prdpiGw/RG', NULL, '2026-01-24 09:55:17', '2026-02-02 16:17:11', 1, 'serviceprovider', 'pending', NULL),
(266, 'Business', NULL, 'Account', 'sasasasas@gmail.com', 14.3300000, 120.9400000, '1212121', NULL, '$2y$10$LsfsIbKd9Chz/aosL.GfHONLOGkOkkiGSgCsZMsre2zR0S70oQrR.', NULL, '2026-01-25 23:47:22', '2026-02-05 01:49:46', 1, 'business', 'rejected', 'sasa'),
(267, 'Business', NULL, 'Account', 'sasaas@gmail.com', 14.3300000, 120.9400000, '1212121', NULL, '$2y$10$ZTeeS5XBWNYDA7IgF85oOOJhZog/IqERUte7b6HAPOmoYnNKzO8mO', NULL, '2026-01-26 00:28:12', '2026-02-05 01:52:37', 1, 'business', 'rejected', 'sasasa'),
(282, 'Business', NULL, 'Account', 'sasass1s@gmail.com', 14.3300000, 120.9400000, '11111', NULL, '$2y$10$nxiinsTk2vHTO7OlhTuZae//R8bd1Ow7ZtShTr.vx.wJUdxvpxLkq', NULL, '2026-01-27 11:36:08', '2026-01-27 13:20:06', 1, 'business', 'rejected', 'sasasasasasasasasasa'),
(291, 'sa', 's', 'sasa', 'sss222@gmail.com', 14.3300000, 120.9400000, '121212', NULL, '$2y$10$TfoEz.qlLnYV0O054zh4ROvztPm/357o1vOuknpQHAEhjDcNVexny', NULL, '2026-01-31 00:02:43', '2026-01-31 00:02:43', 1, 'user', 'pending', NULL),
(292, 'sas', NULL, 'Business', 'sssss1s1@gmail.com', 14.3300000, 120.9400000, '12121212', NULL, '$2y$10$RRUp1DkD9KfPxQDk6zVRr.SCH6n1DH0D3OfbfzT48PtfrsAdvfoFe', NULL, '2026-01-31 00:03:37', '2026-01-31 00:06:35', 1, 'business', 'pending', NULL),
(298, 'ss', 's', 'ss', 'tev21@gmail.com', 14.3300000, 120.9500000, '1212121', NULL, '$2y$10$VAXdM7SB4/1LC4deOHEOIugXQ0oTfd4.ePbdBsrYE/dj4cP03MnuO', NULL, '2026-02-02 17:40:57', '2026-02-02 17:45:39', 1, 'service-provider', 'pending', NULL),
(299, 'sasa', 's', 'sa', 'misa@gmail.com', 14.3300000, 120.9500000, '1212121', NULL, '$2y$10$ITD0lPkrWTQabSVnZ1R0G.om2xPYfwWwxCh9ULVYFRQjGPn5gsl7q', NULL, '2026-02-02 17:46:43', '2026-02-02 17:46:43', 1, 'user', 'pending', NULL),
(300, 'sasasas', NULL, 'Business', 'james@gmail.com', 14.3300000, 120.9500000, '1212121', NULL, '$2y$10$Jl1Gd3kpoIw7s1XXJL6GduUr6HmHwojBd01wtwQPvIdUjUHji0P9y', NULL, '2026-02-02 17:50:18', '2026-02-02 17:50:38', 1, 'business', 'pending', NULL),
(302, 'sa', 's', 'sa', 'sasa@gmail.com', 14.3300000, 120.9500000, '121212', NULL, '$2y$10$2fCgE2TuRHVHefeGFcP1.Ovat2.vQ8wAw14QAn35dBoG5gMhilU6i', NULL, '2026-02-03 12:40:04', '2026-02-03 12:40:04', 1, 'user', 'pending', NULL),
(303, 'sasa', NULL, 'Business', 'asasa@gmail.com', 14.3300000, 120.9500000, '1212121', NULL, '$2y$10$45miNQgnNPI9NHPc3a03XeJ2ZOB55PRdtfE0u.ZgSJmqAstWUfw46', NULL, '2026-02-03 13:27:00', '2026-02-05 01:46:37', 1, 'business', 'rejected', 'sasa'),
(304, 'sasasa', NULL, 'Business', 'sa1111sa@gmail.com', 14.3300000, 120.9500000, '1212121', NULL, '$2y$10$p06..GESKU4GJjnnKwmDvexOWmAabZJ6seGDkyiK8a/HPEMZA/Wnm', NULL, '2026-02-05 01:08:43', '2026-02-05 01:40:47', 1, 'business', 'rejected', 'sasas'),
(305, 'sa', 's', 'sa', 'sasasAA@gmail.com', 14.3300000, 120.9500000, '121212', NULL, '$2y$10$KIbm6TzhvjWXm9jS1JwN.e.x/T72gvt0adUn0hIMpx/172zBotm5.', NULL, '2026-02-05 01:09:27', '2026-02-05 01:09:27', 1, 'user', 'pending', NULL),
(306, 'sa', NULL, 'Business', 'sasa1111@gmail.com', 14.3300000, 120.9500000, '122222222222', NULL, '$2y$10$GcAzSqsJO2gw4tgbxqh6YOGCPZ0jwJJFttAU7Sb2DhBJAwLdZoyLO', NULL, '2026-02-05 01:13:27', '2026-02-05 01:40:12', 1, 'business', 'rejected', 'sasa'),
(307, 'Necessitatibus accus', 'A', 'Nulla assumenda cons', 'fudemomej@mailinator.com', NULL, NULL, NULL, NULL, '$2y$10$vA4SGMHFGrMTNj78xN3.COTRpVC7rm5bVRDeYHaPnUG26NCuPguQa', NULL, '2026-02-05 01:15:16', '2026-02-05 01:15:16', 1, 'finance', 'pending', NULL),
(308, 'sa', NULL, 'Business', '1ss@gmail.com', 14.3300000, 120.9500000, '1212121', NULL, '$2y$10$EoBZqXNRLaPGXLJ9HYgGmuVkPyv4TDW3sqghOkqxBqIFxhVUBSIZC', NULL, '2026-02-05 01:27:13', '2026-02-05 01:27:13', 0, 'business', 'pending', NULL),
(309, 'Et sit non nemo vol', 'N', 'Nulla consequat Vol', 'wevupyzozy@mailinator.com', NULL, NULL, NULL, NULL, '$2y$10$bzFIB0d3Rh6poZ4PuqaBROwO0HaEuTyMr7uErQk7QgfD8zlnLxM1e', NULL, '2026-02-05 01:51:19', '2026-02-05 01:51:19', 1, 'hr', 'pending', NULL),
(310, 'sa', NULL, 'Business', 'asas111a@gmail.com', 14.3300000, 120.9500000, '12121212', NULL, '$2y$10$F9qO5wMvQPkg2V56pjahxOPnR0oc9GbmHabIqwf0I0lkSPqofOmj.', NULL, '2026-02-05 22:41:40', '2026-02-05 22:42:00', 1, 'business', 'pending', NULL),
(311, 'sa', 's', 'sa', 'sasass@gmail.com', 14.3300000, 120.9500000, '12121', NULL, '$2y$10$0.EMjSfHa882RzVNOC4al.FRNI/7eQ6MW2EtVfcqOac8J985sG3xe', NULL, '2026-02-06 02:11:52', '2026-02-06 02:11:52', 1, 'user', 'pending', NULL),
(312, 'sa', NULL, 'Business', 'bus1@gmail.com', 14.3300000, 120.9500000, '12121212', NULL, '$2y$10$U30OuDNfcvUBjoBOS9B6Yu0JL3GXMMTLbT4wZ8Fy35nhE4veyDwia', NULL, '2026-02-06 23:08:23', '2026-02-06 23:09:53', 0, 'business', 'rejected', 'sasa'),
(313, 'sa', NULL, 'Business', 'bu1@gmail.com', 14.3300000, 120.9500000, '121212', NULL, '$2y$10$c1s.1/5IdgWMXjo/kjLcI.Gg7HmW0TjuwOKMn30pBMpk/CYKHD6RK', NULL, '2026-02-06 23:09:40', '2026-02-06 23:10:10', 1, 'business', 'pending', NULL),
(314, 'sa', NULL, 'Business', 'sasasa@gmail.com', 14.3300000, 120.9500000, '1212121', NULL, '$2y$10$NXaAffIRy9NoKEq7NF5QfOIAGkOAdikTaaz/u7WAHaJ4crEPD1fl2', NULL, '2026-02-07 01:48:20', '2026-02-07 01:48:20', 0, 'business', 'pending', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `work_histories`
--

CREATE TABLE `work_histories` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `service_provider_id` bigint(20) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `location` varchar(255) DEFAULT NULL,
  `year` year(4) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `businesses`
--
ALTER TABLE `businesses`
  ADD PRIMARY KEY (`id`),
  ADD KEY `businesses_user_id_foreign` (`user_id`);

--
-- Indexes for table `business_permits`
--
ALTER TABLE `business_permits`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`);

--
-- Indexes for table `migrations`
--
ALTER TABLE `migrations`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`email`);

--
-- Indexes for table `permits`
--
ALTER TABLE `permits`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  ADD KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`);

--
-- Indexes for table `request_materials`
--
ALTER TABLE `request_materials`
  ADD PRIMARY KEY (`id`),
  ADD KEY `request_materials_service_request_id_foreign` (`service_request_id`);

--
-- Indexes for table `reviews`
--
ALTER TABLE `reviews`
  ADD PRIMARY KEY (`id`),
  ADD KEY `reviews_user_id_foreign` (`user_id`),
  ADD KEY `reviews_service_provider_id_foreign` (`service_provider_id`);

--
-- Indexes for table `service_material_templates`
--
ALTER TABLE `service_material_templates`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `service_providers`
--
ALTER TABLE `service_providers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `service_providers_user_id_foreign` (`user_id`);

--
-- Indexes for table `service_provider_applications`
--
ALTER TABLE `service_provider_applications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `service_provider_applications_user_id_foreign` (`user_id`);

--
-- Indexes for table `service_requests`
--
ALTER TABLE `service_requests`
  ADD PRIMARY KEY (`id`),
  ADD KEY `service_requests_user_id_foreign` (`user_id`),
  ADD KEY `service_requests_service_provider_id_foreign` (`service_provider_id`);

--
-- Indexes for table `service_request_proofs`
--
ALTER TABLE `service_request_proofs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `service_request_proofs_service_request_id_foreign` (`service_request_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `users_email_unique` (`email`);

--
-- Indexes for table `work_histories`
--
ALTER TABLE `work_histories`
  ADD PRIMARY KEY (`id`),
  ADD KEY `work_histories_service_provider_id_foreign` (`service_provider_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `businesses`
--
ALTER TABLE `businesses`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=98;

--
-- AUTO_INCREMENT for table `business_permits`
--
ALTER TABLE `business_permits`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `failed_jobs`
--
ALTER TABLE `failed_jobs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `migrations`
--
ALTER TABLE `migrations`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=45;

--
-- AUTO_INCREMENT for table `permits`
--
ALTER TABLE `permits`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `personal_access_tokens`
--
ALTER TABLE `personal_access_tokens`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `request_materials`
--
ALTER TABLE `request_materials`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `reviews`
--
ALTER TABLE `reviews`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `service_material_templates`
--
ALTER TABLE `service_material_templates`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `service_providers`
--
ALTER TABLE `service_providers`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=105;

--
-- AUTO_INCREMENT for table `service_provider_applications`
--
ALTER TABLE `service_provider_applications`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `service_requests`
--
ALTER TABLE `service_requests`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `service_request_proofs`
--
ALTER TABLE `service_request_proofs`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=316;

--
-- AUTO_INCREMENT for table `work_histories`
--
ALTER TABLE `work_histories`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `businesses`
--
ALTER TABLE `businesses`
  ADD CONSTRAINT `businesses_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `request_materials`
--
ALTER TABLE `request_materials`
  ADD CONSTRAINT `request_materials_service_request_id_foreign` FOREIGN KEY (`service_request_id`) REFERENCES `service_requests` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `reviews`
--
ALTER TABLE `reviews`
  ADD CONSTRAINT `reviews_service_provider_id_foreign` FOREIGN KEY (`service_provider_id`) REFERENCES `service_providers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `reviews_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `service_providers`
--
ALTER TABLE `service_providers`
  ADD CONSTRAINT `service_providers_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `service_provider_applications`
--
ALTER TABLE `service_provider_applications`
  ADD CONSTRAINT `service_provider_applications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `service_requests`
--
ALTER TABLE `service_requests`
  ADD CONSTRAINT `service_requests_service_provider_id_foreign` FOREIGN KEY (`service_provider_id`) REFERENCES `service_providers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `service_requests_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `service_request_proofs`
--
ALTER TABLE `service_request_proofs`
  ADD CONSTRAINT `service_request_proofs_service_request_id_foreign` FOREIGN KEY (`service_request_id`) REFERENCES `service_requests` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `work_histories`
--
ALTER TABLE `work_histories`
  ADD CONSTRAINT `work_histories_service_provider_id_foreign` FOREIGN KEY (`service_provider_id`) REFERENCES `service_providers` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
