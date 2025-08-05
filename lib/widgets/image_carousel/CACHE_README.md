# 轮播图缓存功能说明

## 概述

轮播图组件现已支持图片缓存功能，通过集成 `cached_network_image` 包，提供了高效的图片缓存解决方案。

## 功能特性

### 1. 内存缓存
- 图片存储在内存中，提供快速访问
- 可配置内存缓存大小，优化内存使用
- 支持自定义缓存键，避免缓存冲突

### 2. 磁盘缓存
- 图片持久化存储在设备磁盘上
- 应用重启后仍可访问缓存的图片
- 可配置磁盘缓存大小限制

### 3. 预加载功能
- 自动预加载前后图片，提升切换体验
- 可配置预加载数量
- 支持启用/禁用预加载功能

### 4. 错误处理
- 图片加载失败时自动重试
- 可配置最大重试次数和重试延迟
- 自定义错误显示组件

## 使用方法

### 基本用法

```dart
ImageCarousel(
  images: [
    'https://example.com/image1.jpg',
    'https://example.com/image2.jpg',
    'https://example.com/image3.jpg',
  ],
  enableCache: true, // 启用缓存
  autoPlay: true,
  autoPlayInterval: const Duration(seconds: 3),
)
```

### 高级配置

```dart
ImageCarousel(
  images: imageList,
  enableCache: true,
  enablePreload: true,
  preloadCount: 2,
  
  // 内存缓存配置
  memCacheWidth: 800,
  memCacheHeight: 600,
  
  // 磁盘缓存配置
  maxWidthDiskCache: 1024,
  maxHeightDiskCache: 768,
  
  // 缓存策略
  useOldImageOnUrlChange: true,
  
  // 错误处理
  enableErrorRetry: true,
  maxRetryCount: 3,
  retryDelay: const Duration(seconds: 2),
  
  // 占位符和错误组件
  placeholder: CustomLoadingWidget(),
  errorWidget: CustomErrorWidget(),
)
```

## 配置参数说明

### 缓存相关参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enableCache` | `bool` | `true` | 是否启用图片缓存 |
| `memCacheWidth` | `int?` | `800` | 内存缓存图片宽度 |
| `memCacheHeight` | `int?` | `600` | 内存缓存图片高度 |
| `maxWidthDiskCache` | `int?` | `1024` | 磁盘缓存最大宽度 |
| `maxHeightDiskCache` | `int?` | `768` | 磁盘缓存最大高度 |
| `useOldImageOnUrlChange` | `bool` | `true` | URL变化时是否使用旧图片 |

### 预加载相关参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enablePreload` | `bool` | `true` | 是否启用预加载 |
| `preloadCount` | `int` | `2` | 预加载图片数量 |

### 错误处理参数

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `enableErrorRetry` | `bool` | `true` | 是否启用错误重试 |
| `maxRetryCount` | `int` | `3` | 最大重试次数 |
| `retryDelay` | `Duration` | `2秒` | 重试延迟时间 |
| `placeholder` | `Widget?` | `null` | 加载占位符 |
| `errorWidget` | `Widget?` | `null` | 错误显示组件 |

## 性能优化建议

### 1. 缓存大小配置
- 根据设备性能和内存情况调整缓存大小
- 建议内存缓存不超过设备可用内存的 10%
- 磁盘缓存大小建议不超过 100MB

### 2. 预加载策略
- 预加载数量建议设置为 1-3 张
- 在内存受限的设备上可以减少预加载数量
- 网络较慢时可以增加预加载数量

### 3. 错误处理
- 设置合理的重试次数，避免无限重试
- 提供友好的错误提示和重试按钮
- 考虑网络状况调整重试延迟

## 注意事项

1. **依赖包**: 需要添加 `cached_network_image: ^3.3.1` 依赖
2. **权限**: 磁盘缓存需要存储权限（Android）
3. **内存管理**: 大量图片时注意内存使用情况
4. **网络优化**: 建议使用 CDN 和图片压缩
5. **缓存清理**: 应用退出时缓存会自动清理

## 示例代码

完整的使用示例请参考 `lib/demos/carousel_cache_demo.dart` 文件。

## 更新日志

- **v1.0.0**: 初始版本，支持基本的图片缓存功能
- **v1.1.0**: 添加预加载和错误重试功能
- **v1.2.0**: 优化缓存配置和性能 