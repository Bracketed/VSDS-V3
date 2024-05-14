namespace YolusCORE.Extensions
{
	public static class StringExtensions
	{
		public static string Substring(this string @this, string from = null, string until = null, StringComparison comparison = StringComparison.InvariantCulture)
		{
			var fromLength = (from ?? string.Empty).Length;
			var startIndex = !string.IsNullOrEmpty(from)
								 ? @this.IndexOf(from, comparison) + fromLength
								 : 0;

			if (startIndex < fromLength)
				return null;

			var endIndex = !string.IsNullOrEmpty(until)
							   ? @this.IndexOf(until, startIndex, comparison)
							   : @this.Length;

			if (endIndex < 0)
				return null;

			var subString = @this[startIndex..endIndex];
			return subString;
		}
	}
}