/// **Author**: wwyang
/// **Date**: 2025.5.8
/// **Copyright**: Multimedia Lab, Zhejiang Gongshang University
/// **Version**: 1.0
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
/// GNU General Public License for more details.
///
/// You should have received a copy of the GNU General Public License
/// along with this program. If not, see <http://www.gnu.org/licenses/>.
library repository_lib;

abstract class BaseRepository {

  BaseRepository(){

  }

  /// 抽象方法：释放当前数据仓库所持有的资源。
  /// 所有实现 BaseRepository 的具体仓库类都必须实现此方法。
  Future<void> freeRepository();
}
