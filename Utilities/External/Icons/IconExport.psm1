Function Export-Icon {
<#
	.SYNOPSIS
	Export-Icon exports high-quality icons stored within .DLL and .EXE files.

	.DESCRIPTION
	Export-Icon can export to a number of formats, including ico, bmp, png, jpg, gif, emf, exif, icon, tiff, and wmf. In addition, it can also export to a different size.

	This function quickly exports *all* icons stored within the resource file.

	.PARAMETER Path
	Path to the .dll or .exe

	.PARAMETER Directory
	Directory where the exports should be stored. If no directory is specified, all icons will be exported to the TEMP directory.

	.PARAMETER Size
	This specifies the pixel size of the exported icons. All icons will be squares, so if you want a 16x16 export, it would be -Size 16.

	Valid sizes are 8, 16, 24, 32, 48, 64, 96, and 128. The default is 32.

	.PARAMETER Type
	This is the type of file you would like to export to. The default is .ico

	Valid types are ico, bmp, png, jpg, gif, emf, exif, icon, tiff, and wmf. The default is ico.

	.NOTES
	Author: Chrissy LeMaire
	Requires: PowerShell 3.0
	Version: 2.0
	DateUpdated: 2016-June-6

	.LINK
	https://gallery.technet.microsoft.com/scriptcenter/Export-Icon-from-DLL-and-9d309047

	.EXAMPLE
	Export-Icon C:\windows\system32\imageres.dll

	Exports all icons stored witin C:\windows\system32\imageres.dll to $env:temp\icons. Creates directory if required and automatically opens output directory.

	.EXAMPLE
	Export-Icon -Path "C:\Program Files (x86)\VMware\Infrastructure\Virtual Infrastructure Client\Launcher\VpxClient.exe" -Size 64 -Type png -Directory C:\temp

	Exports the high-quality icon within VpxClient.exe to a transparent png in C:\temp\. Resizes the exported image to 64x64. Creates directory if required
	and automatically opens output directory.


	#>

    [CmdletBinding()]
	Param(
        	[Parameter(Mandatory=$true)]
        	[string]$Path,
			[Parameter()]
			[string]$Directory,
			[Parameter()]
			[ValidateSet(8,16,24,32,48,64,96,128)]
			[int]$Size = 32,
			[Parameter()]
			[ValidateSet("ico","bmp","png","jpg","gif", "jpeg", "emf", "exif", "icon", "tiff", "wmf")]
			[string]$Type = "ico"
	)

	BEGIN {

	# Thanks Thomas Levesque at http://bit.ly/1KmLgyN and darkfall http://git.io/vZxRK
	$code = '
    using System;
    using System.Drawing;
    using System.Runtime.InteropServices;
	using System.IO;

    namespace System {
        public class IconExtractor {
            public static Icon Extract(string file, int number, bool largeIcon) {
                IntPtr large;
                IntPtr small;
                ExtractIconEx(file, number, out large, out small, 1);
                try  { return Icon.FromHandle(largeIcon ? large : small); }
                catch  { return null; }
            }
            [DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
            private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);
        }
    }

	public class PngIconConverter
    {
        public static bool Convert(System.IO.Stream input_stream, System.IO.Stream output_stream, int size, bool keep_aspect_ratio = false)
        {
            System.Drawing.Bitmap input_bit = (System.Drawing.Bitmap)System.Drawing.Bitmap.FromStream(input_stream);
            if (input_bit != null)
            {
                int width, height;
                if (keep_aspect_ratio)
                {
                    width = size;
                    height = input_bit.Height / input_bit.Width * size;
                }
                else
                {
                    width = height = size;
                }
                System.Drawing.Bitmap new_bit = new System.Drawing.Bitmap(input_bit, new System.Drawing.Size(width, height));
                if (new_bit != null)
                {
                    System.IO.MemoryStream mem_data = new System.IO.MemoryStream();
                    new_bit.Save(mem_data, System.Drawing.Imaging.ImageFormat.Png);

                    System.IO.BinaryWriter icon_writer = new System.IO.BinaryWriter(output_stream);
                    if (output_stream != null && icon_writer != null)
                    {
                        icon_writer.Write((byte)0);
                        icon_writer.Write((byte)0);
                        icon_writer.Write((short)1);
                        icon_writer.Write((short)1);
                        icon_writer.Write((byte)width);
                        icon_writer.Write((byte)height);
                        icon_writer.Write((byte)0);
                        icon_writer.Write((byte)0);
                        icon_writer.Write((short)0);
                        icon_writer.Write((short)32);
                        icon_writer.Write((int)mem_data.Length);
                        icon_writer.Write((int)(6 + 16));
						icon_writer.Write(mem_data.ToArray());
						icon_writer.Flush();
                        return true;
                    }
                }
                return false;
            }
            return false;
        }

        public static bool Convert(string input_image, string output_icon, int size, bool keep_aspect_ratio = false)
        {
            System.IO.FileStream input_stream = new System.IO.FileStream(input_image, System.IO.FileMode.Open);
            System.IO.FileStream output_stream = new System.IO.FileStream(output_icon, System.IO.FileMode.OpenOrCreate);

            bool result = Convert(input_stream, output_stream, size, keep_aspect_ratio);

            input_stream.Close();
            output_stream.Close();

            return result;
        }
    }
'

   Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing, System.IO -ErrorAction SilentlyContinue

	PROCESS {
			switch ($type) {
				"jpg" { $type = "jpeg"}
				"icon" { $type = "ico"}
			}

			# Ensure file exists
			$path = Resolve-Path $path
			if ((Test-Path $path) -eq $false) { throw "$path does not exist." }

			# Ensure directory exists if one was specified. Otherwise, create icon directory in TEMP
			if ($directory.length -eq 0) { $directory = "$env:temp\icons" }
			if ((Test-Path $directory) -eq $false) {
				try { New-Item -Type Directory $directory | Out-Null }
				catch { throw "Can't create $directory" }
			}

			# Extract
			$index = 0
			$tempfile = "$directory\tempicon.png"
			$basename = [io.path]::GetFileNameWithoutExtension($path)

			do {
				try { $icon = [System.IconExtractor]::Extract($path, $index, $true) }
				catch { throw "Could not extract icon. Do you have the proper permissions?" }

				if ($null -ne $icon) {

					$filepath = "$directory\$basename-$index.$type"
					# Convert to bitmap, otherwise it's ugly
					$bmp = $icon.ToBitmap()

					try {
						if ($type -eq "ico") {
							$bmp.Save($tempfile,"png")
							[PngIconConverter]::Convert($tempfile,$filepath,$size,$true) | Out-Null
							# Keep remove-item from complaining about weird directories
							cmd /c del $tempfile
						} else {
						if ($bmp.Width -ne $size) {
							# Needs to be resized
							$newbmp = New-Object System.Drawing.Bitmap($size, $size)
							$graph = [System.Drawing.Graphics]::FromImage($newbmp)

							# Make it transparent
							$graph.clear([System.Drawing.Color]::Transparent)
							$graph.DrawImage($bmp,0,0,$size,$size)

							#save to file
							$newbmp.Save($filepath,$type)
							$newbmp.Dispose()
						} else { $bmp.Save($filepath,$type) }

						$bmp.Dispose()
						}
					$icon.Dispose()
					$index++
					} catch { throw "Could not convert icon." }

				}
			} while ($null -ne $icon)

			# Open directory
			if ($index -eq 0) { Write-Error "No icons to extract :("} else { Invoke-Item $directory }
		}
	}
}